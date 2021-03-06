import QtQuick 2.6
import QtQuick.Layouts 1.3
import JAGCS 1.0

import "qrc:/Controls" as Controls

import "RadioStatus"
import "Connection"

Rectangle {
    id: topbar

    property alias burgerHovered: burger.hovered // NOTE: QTBUG-59141

    color: customPalette.backgroundColor
    height: sizings.controlBaseSize

    Controls.Shadow {
        source: parent
    }

    TopbarPresenter {
        id: presenter
        view: topbar
    }

    RowLayout {
        id: buttonRow
        anchors.left: parent.left
        height: parent.height
        spacing: sizings.spacing

        Controls.Button {
            id: burger
            iconSource: "qrc:/icons/burger.svg"
            tipText: qsTr("Menu")
            flat: true
            onPressed: menu.open()
        }

        Controls.Button {
            iconSource: "qrc:/icons/planning.svg"
            tipText: qsTr("Planning")
            flat: true
            onClicked: menu.setMode(DrawerPresenter.Planning)
        }

        Controls.Button {
            iconSource: "qrc:/icons/fleet.svg"
            tipText: qsTr("Vehicles")
            flat: true
            onClicked: menu.setMode(DrawerPresenter.Vehicles)
        }

        Controls.Button {
            iconSource: connection.connected ? "qrc:/icons/connect.svg" : "qrc:/icons/disconnect.svg"
            iconColor: connection.connected ? customPalette.textColor : customPalette.dangerColor
            tipText: qsTr("Connection")
            flat: true
            onClicked: menu.setMode(DrawerPresenter.Connection)
        }
    }

    RowLayout {
        anchors.left: buttonRow.right
        anchors.right: parent.right
        anchors.rightMargin: dashboard.width
        height: parent.height
        spacing: sizings.spacing
        clip: true

        ConnectionView {
            id: connection
        }

        RadioStatusView {
            id: radioStatus
        }
    }
}
