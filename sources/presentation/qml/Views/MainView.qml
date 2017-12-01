import QtQuick 2.6

import "../Controls" as Controls

import "Topbar"
import "Map"
import "Video"
import "Menu"

Rectangle {
    id: main

    property bool cornerMap: false
    property bool cornerVisible: false
    property int mapType: -1

    property Component mapComponent

    property QtObject map
    property QtObject video

    function reloadMap(type) {
        mapType = type !== undefined ? type : parseInt(settings.value("Map/plugin"));
        mapComponent = mapFactory.create(mapType);
    }

    color: palette.backgroundColor
    Component.onCompleted: reloadMap()

    TopbarView {
        id: topbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Loader {
        id: substrate
        anchors.left: parent.left
        anchors.top: topbar.bottom
        width: menuDrawer.visible ? menuDrawer.x : parent.width
        anchors.bottom: parent.bottom
        sourceComponent: cornerMap ? videoComponent : mapComponent
        onItemChanged: if (item) cornerMap ? video = item : map = item;
    }

    MapControl { // TODO: to ToolsPanel
        id: tools
        anchors.right: substrate.right
        anchors.bottom: parent.bottom
        anchors.margins: sizings.margins

        Controls.Button {
            tipText: cornerMap ? qsTr("Map") : qsTr("Video")
            iconSource: cornerMap ? "qrc:/icons/map-marker.svg" : "qrc:/icons/video.svg"
            onClicked: cornerMap = !cornerMap
        }

        Controls.Button {
            id: maxMinButton
            tipText: cornerVisible ? qsTr("Hide window") : qsTr("Show window")
            iconSource: cornerVisible ? "qrc:/icons/window.svg" : "qrc:/icons/subwindow.svg"
            onClicked: cornerVisible = !cornerVisible
        }
    }

    Loader {
        id: corner
        anchors.bottom: parent.bottom
        anchors.right: tools.left
        anchors.margins: sizings.margins
        width: Math.min(parent.width / 3, parent.height / 3)
        sourceComponent: cornerMap ? mapComponent : videoComponent
        visible: cornerVisible
        onItemChanged: if (item) cornerMap ? map = item : video = item;
        z: 1
    }

    Controls.Drawer {
        id: menuDrawer
        width: menu.width
        height: parent.height
        edge: Qt.RightEdge

        MenuView {
            id: menu
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }

    Controls.Button {
        id: menuButton
        tipText: qsTr("Menu")
        iconSource: "qrc:/icons/burger.svg"
        anchors.top: parent.top
        anchors.right: parent.right
        highlighted: menuDrawer.position == 1.0
        onClicked: menuDrawer.isOpened ? menuDrawer.close() : menuDrawer.open()
    }

    MapFactory { id: mapFactory }
    Component { id: videoComponent; ActiveVideoView { id: video } }
}
