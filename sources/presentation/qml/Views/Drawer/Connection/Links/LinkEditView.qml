import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtCharts 2.0
import JAGCS 1.0

import "qrc:/Controls" as Controls
import "qrc:/Indicators" as Indicators
import "qrc:/Views/Common"

ColumnLayout {
    id: linkEditView

    property int linkId: 0
    property bool connected: false
    property bool changed: false

    property int type: LinkDescription.UnknownType
    property int protocol: LinkDescription.UnknownProtocol
    property string device
    property int baudRate
    property var statistics

    property alias name: nameField.text
    property alias devices: deviceBox.model
    property alias baudRates: baudBox.model
    property alias port: portBox.value
    property alias endpoints: endpointList.endpoints
    property alias autoResponse: autoResponseBox.checked

    onChangedChanged: {
        if (changed) return;

        endpointList.updateEndpoints(false);

        if (linkId > 0)
        {
            if (name.length > 0) menu.submode = name;
            else menu.submode = qsTr("Link");
        }
        else menu.submode = "";
    }
    onDeviceChanged: deviceBox.currentIndex = deviceBox.model.indexOf(device)
    onBaudRateChanged: baudBox.currentIndex = baudBox.model.indexOf(baudRate)
    onLinkIdChanged: presenter.setLink(linkId);
//    onNameChanged: {
//        if (linkId > 0)
//        {
//            if (name.length > 0) menu.submode = name;
//            else menu.submode = qsTr("Link");
//        }
//        else menu.submode = "";
//    }
    Component.onDestruction: menu.submode = ""

    spacing: sizings.spacing

    LinkEditPresenter {
        id: presenter
        view: linkEditView
        Component.onCompleted: updateRates()
    }

    Controls.Label {
        text: {
            var str = qsTr("Type");
            switch (type) {
            case LinkDescription.Udp: return str + ": " + qsTr("UDP");
            case LinkDescription.Serial: return str + ": " + qsTr("Serial");
            default: return str + ": " + qsTr("Unknown");
            }
        }
        Layout.fillWidth: true
    }

    Controls.Label {
        text: {
            var str = qsTr("Protocol");
            switch (protocol) {
            case LinkDescription.MavLink1: return str + ": " + "MAVLink v1";
            case LinkDescription.MavLink2: return str + ": " + "MAVLink v2";
            case LinkDescription.UnknownProtocol:
            default: return str + ": " + qsTr("Unknown");
            }
        }
        Layout.fillWidth: true
    }

    Controls.TextField {
        id: nameField
        labelText: qsTr("Name")
        placeholderText: qsTr("Enter name")
        onEditingFinished: changed = true
        Layout.fillWidth: true
    }

    Controls.ComboBox {
        id: deviceBox
        labelText: qsTr("Device")
        visible: type == LinkDescription.Serial
        model: []
        onDisplayTextChanged: {
            device = displayText;
            changed = true;
        }
        Layout.fillWidth: true
    }

    Controls.ComboBox {
        id: baudBox
        labelText: qsTr("Baud rate")
        visible: type == LinkDescription.Serial
        model: []
        onDisplayTextChanged: {
            baudRate = displayText;
            changed = true;
        }
        Layout.fillWidth: true
    }

    Controls.SpinBox {
        id: portBox
        labelText: qsTr("Port")
        from: 0
        to: 65535
        visible: type == LinkDescription.Udp
        onValueChanged: changed = true
        Layout.fillWidth: true
    }

    Controls.Label {
        text: qsTr("Setted endpoints")
        visible: type == LinkDescription.Udp
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }

    EndpointListView {
        id: endpointList
        visible: type == LinkDescription.Udp
        onChanged: linkEditView.changed = true;
        Layout.maximumHeight: sizings.controlBaseSize * 6
        Layout.fillWidth: true
    }

    Controls.CheckBox {
        id: autoResponseBox
        text: qsTr("Autoresponse on get data")
        visible: type == LinkDescription.Udp
        horizontalAlignment: Text.AlignHCenter
        onCheckedChanged: changed = true
        Layout.fillWidth: true
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Indicators.MiniPlot {
            id: plot
            width: parent.width
            height: Math.min(width / 2, parent.height)
            visible: parent.height > 5
            anchors.bottom: parent.bottom

            ValueAxis {
                id: timeAxis
                visible: false
                min: statistics.minTime
                max: statistics.maxTime
            }

            AreaSeries {
                color: customPalette.positiveColor
                borderColor: customPalette.positiveColor
                borderWidth: 3
                opacity: 0.33
                axisX: timeAxis
                axisY: ValueAxis {
                    titleText: qsTr("Recv.")
                    titleFont.pixelSize: sizings.fontSize * 0.5
                    labelsFont.pixelSize: 1
                    labelsVisible: false
                    color: customPalette.positiveColor
                    max: statistics.maxRecv
                }
                upperSeries: LineSeries {
                    VXYModelMapper {
                        xColumn: 0
                        yColumn: 1
                        model: statistics
                    }
                }
            }

            AreaSeries {
                color: customPalette.skyColor
                borderColor: customPalette.skyColor
                borderWidth: 3
                opacity: 0.33
                axisX: timeAxis
                axisYRight: ValueAxis {
                    titleText: qsTr("Sent")
                    titleFont.pixelSize: sizings.fontSize * 0.5
                    labelsVisible: false
                    labelsFont.pixelSize: 1
                    color: customPalette.skyColor
                    max: statistics.maxSent
                }
                upperSeries: LineSeries {
                    VXYModelMapper {
                        xColumn: 0
                        yColumn: 2
                        model: statistics
                    }
                }
            }
        }
    }

    Controls.Button {
        enabled: !changed
        text: connected ? qsTr("Disconnect") : qsTr("Connect")
        iconSource: connected ? "qrc:/icons/disconnect.svg" : "qrc:/icons/connect.svg"
        onClicked: presenter.setConnected(!connected)
        Layout.fillWidth: true
    }

    SaveRestore {
        enabled: changed
        onSave: presenter.save()
        onRestore: presenter.updateLink()
    }
}

