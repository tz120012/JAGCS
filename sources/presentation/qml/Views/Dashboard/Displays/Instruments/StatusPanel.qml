import QtQuick 2.6
import QtQuick.Layouts 1.3
import JAGCS 1.0

import "qrc:/JS/helper.js" as Helper
import "qrc:/Controls" as Controls
import "qrc:/Indicators" as Indicators

Controls.Pane {
    id: root

    property bool dmsFormat: settings.boolValue("Gui/coordinatesDms")

    RowLayout {
        anchors.centerIn: parent
        width: parent.width
        opacity: satelliteEnabled ? 1 : 0.33
        spacing: sizings.spacing

        Controls.ColoredIcon {
            opacity: enabled ? 1 : 0.33
            color: {
                switch (fix) {
                case -1:
                case 0: return palette.sunkenColor;
                case 1: return palette.dangerColor;
                case 2: return palette.cautionColor;
                case 3:
                default: return palette.positiveColor;
                }
            }
            source: "qrc:/icons/gps.svg"
            height: sizings.controlBaseSize
            width: height
            Layout.alignment: Qt.AlignRight

            Text {
                text: satellitesVisible
                font.pixelSize: parent.height / 4
                font.bold: true
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: parent.color
            }
        }

        ColumnLayout {
            id: column
            Layout.fillWidth: true
            spacing: sizings.spacing

            Controls.Label {
                font.pixelSize: Math.max(root.width * 0.04, sizings.fontPixelSize * 0.5)
                font.bold: true
                opacity: enabled ? 1 : 0.33
                color: satelliteOperational ? palette.textColor : palette.dangerColor
                text: qsTr("Lat.: ") + (dmsFormat ?
                                            Helper.degreesToDmsString(coordinate.latitude, false) :
                                            Helper.degreesToString(coordinate.latitude, 6))
            }

            Controls.Label {
                font.pixelSize: Math.max(root.width * 0.04, sizings.fontPixelSize * 0.5)
                font.bold: true
                opacity: enabled ? 1 : 0.33
                color: satelliteOperational ? palette.textColor : palette.dangerColor
                text: qsTr("Lon.: ") + (dmsFormat ?
                                            Helper.degreesToDmsString(coordinate.longitude, true) :
                                            Helper.degreesToString(coordinate.longitude, 6))
            }
        }

//        ColumnLayout { TODO: to satellites tooltip
//            Layout.alignment: Qt.AlignRight

//            Controls.Label {
//                font.pixelSize: Math.max(root.width * 0.04, sizings.fontPixelSize * 0.5)
//                font.bold: true
//                opacity: enabled ? 1 : 0.33
//                color: satelliteOperational ? palette.textColor : palette.dangerColor
//                text: qsTr("HDOP: ") + eph
//            }

//            Controls.Label {
//                font.pixelSize: Math.max(root.width * 0.04, sizings.fontPixelSize * 0.5)
//                font.bold: true
//                opacity: enabled ? 1 : 0.33
//                color: satelliteOperational ? palette.textColor : palette.dangerColor
//                text: qsTr("VDOP: ") + epv
//            }
//        }

        Item {
            Layout.fillWidth: true
        }

        Indicators.BatteryIndicator {
            id: battery
            percentage: batteryPercentage
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignRight

            Controls.Label {
                font.pixelSize: sizings.fontPixelSize * 0.6
                font.bold: true
                color: batteryVoltage > 0.01 ? palette.textColor : palette.sunkenColor
                text: batteryVoltage.toFixed(2) + qsTr(" V")
            }

            Controls.Label {
                font.pixelSize: sizings.fontPixelSize * 0.6
                font.bold: true
                color: {
                    if (batteryCurrent < -0.01) return palette.positiveColor;
                    if (batteryCurrent > 0.0) return palette.textColor;
                    if (batteryCurrent > 5.0) return palette.cautionColor;
                    if (batteryCurrent > 10.0) return palette.dangerColor;

                    return palette.sunkenColor;
                }
                text: batteryCurrent.toFixed(2) + qsTr(" A")
            }
        }
    }
}