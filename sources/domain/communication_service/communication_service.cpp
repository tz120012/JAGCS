#include "communication_service.h"

// Qt
#include <QMap>
#include <QDebug>

// Internal
#include "db_facade.h"
#include "link_description.h"

#include "abstract_communicator.h"
#include "abstract_link.h"
#include "description_link_factory.h"

#include "i_communicator_factory.h"

using namespace db;
using namespace comm;
using namespace domain;

class CommunicationService::Impl
{
public:
    AbstractCommunicator* communicator;
    DbFacade* facade;

    db::LinkDescriptionPtrList descriptions;
    QMap<db::LinkDescriptionPtr, AbstractLink*> descriptedLinks;

    AbstractLink* linkFromDescription(const LinkDescriptionPtr& description)
    {
        DescriptionLinkFactory factory(description);
        AbstractLink* link = factory.create();
        if (!link) return nullptr;

        descriptedLinks[description] = link;
        communicator->addLink(link);

        if (description->isAutoConnect()) link->connectLink();

        return link;
    }

    void updateLinkFromDescription(AbstractLink* link,
                                   const LinkDescriptionPtr& description)
    {
        DescriptionLinkFactory factory(description);
        factory.update(link);
    }
};

CommunicationService::CommunicationService(ICommunicatorFactory* commFactory,
                                           DbFacade* facade,
                                           QObject* parent):
    QObject(parent),
    d(new Impl())
{
    d->communicator = commFactory->create();
    d->facade = facade;

    for (const LinkDescriptionPtr& description: facade->links())
    {
        d->descriptions.append(description);
        AbstractLink* link = d->linkFromDescription(description);
        link->setParent(this);
        connect(link, &AbstractLink::statisticsChanged,
                this, &CommunicationService::onLinkStatisticsChanged);
    }
}

CommunicationService::~CommunicationService()
{
    for (const LinkDescriptionPtr& description: d->descriptions)
    {
        d->facade->save(description);
    }
}

LinkDescriptionPtrList CommunicationService::links() const
{
    return d->descriptions;
}

void CommunicationService::saveLink(const LinkDescriptionPtr& description)
{
    AbstractLink* link;

    if (d->descriptions.contains(description))
    {
        link = d->descriptedLinks[description];
        d->updateLinkFromDescription(link, description);
    }
    else
    {
        d->descriptions.append(description);
        link = d->linkFromDescription(description);
        link->setParent(this);
        connect(link, &AbstractLink::statisticsChanged,
                this, &CommunicationService::onLinkStatisticsChanged);
        d->communicator->addLink(link);
        emit linkAdded(description);
    }

    if (description->isAutoConnect() != link->isConnected())
    {
        link->setConnected(description->isAutoConnect());
        description->setAutoConnect(link->isConnected());
    }

    emit linkChanged(description);

    d->facade->save(description);
}

void CommunicationService::removeLink(const LinkDescriptionPtr& description)
{
    d->descriptions.removeOne(description);
    AbstractLink* link = d->descriptedLinks.take(description);
    d->communicator->removeLink(link);
    delete link;

    d->facade->remove(description);
    emit linkRemoved(description);
}

void CommunicationService::onLinkStatisticsChanged()
{
    AbstractLink* link = qobject_cast<AbstractLink*>(this->sender());

    emit linkStatisticsChanged(d->descriptedLinks.key(link),
                               link->bytesSentSec(),
                               link->bytesReceivedSec());
}
