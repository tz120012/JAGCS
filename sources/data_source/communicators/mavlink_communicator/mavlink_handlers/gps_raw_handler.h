#ifndef GPS_RAW_HANDLER_H
#define GPS_RAW_HANDLER_H

#include "abstract_mavlink_handler.h"

namespace data_source
{
    class GpsRawHandler: public AbstractMavLinkHandler
    {
    public:
        GpsRawHandler();

    protected:
        int messageId() const override;
        void processMessage(const mavlink_message_t& message) override;
    };
}

#endif // GPS_RAW_HANDLER_H
