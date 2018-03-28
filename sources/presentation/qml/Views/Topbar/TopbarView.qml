import QtQuick 2.6
import QtQuick.Layouts 1.3
import JAGCS 1.0

import "qrc:/Controls" as Controls

import "RadioStatus"
import "Connection"

Item {
    id: topbar

    height: sizings.controlBaseSize

    TopbarPresenter {
        id: presenter
        view: topbar
    }

    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: dashboard.width
        spacing: sizings.spacing

        Controls.Button {
            iconSource: "qrc:/icons/burger.svg"
            tipText: qsTr("Menu")
            flat: true
            onClicked: menu.home()
        }

        Controls.Button {
            iconSource: "qrc:/icons/planning.svg"
            tipText: qsTr("Planning")
            flat: true
            onClicked: menu.goTo("qrc:/Views/Menu/Planning/PlanningView.qml", qsTr("Planning"), {})
        }

        Controls.Button {
            iconSource: "qrc:/icons/flight.svg"
            tipText: qsTr("Vehicles")
            flat: true
            onClicked: menu.goTo("qrc:/Views/Menu/Vehicles/VehicleListView.qml", qsTr("Vehicles"), {})
        }

        Controls.Button {
            iconSource: connection.connected ? "qrc:/icons/connect.svg" :
                                               "qrc:/icons/disconnect.svg"
            iconColor: connection.connected ? customPalette.textColor :
                                              customPalette.dangerColor
            tipText: qsTr("Links")
            flat: true
            onClicked: menu.goTo("qrc:/Views/Menu/Links/LinkListView.qml", qsTr("Links"), {})
        }

        Item {
            Layout.fillWidth: true
        }

        ConnectionView {
            id: connection
        }

        RadioStatusView {
            id: radioStatus
            Layout.preferredWidth: sizings.controlBaseSize * 2
        }
    }
}
