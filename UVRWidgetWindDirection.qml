/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.11
import QtQuick.Controls             2.4
import QtQuick.Dialogs              1.3
import QtQuick.Layouts              1.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

Item {
    id:             _root
    width:          uvrIndicatorRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    visible:        true

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    property var        _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property double     lat:                 _activeVehicle ? _activeVehicle.getFactGroup("gps").getFact("lat").value    : 46
    property double     lon:                 _activeVehicle ? _activeVehicle.getFactGroup("gps").getFact("lon").value    : 16
    property real       rotationInput:       rotationState < 0 ? rotationState + 360 : rotationState
    property real       rotationState:       _checkedAPI ? _windWidgetPostDirection < 0 ? _windWidgetPostDirection + 360 : _windWidgetPostDirection : _windImageRotation > 270 ? _windImageRotation - 270 : _windImageRotation + 90
    property real       windSpeedValue:      _checkedAPI ? _windWidgetPostSpeed : 0.0

    property bool       _checkedAPI:                 false
    property real       _windImageRotation:          0.0
    property real       _windWidgetPostDirection:    0.0
    property real       _windWidgetPostSpeed:        0.0
    property bool       _windImageCompleted:         false
    property bool       _enableRotateMap:            QGroundControl.settingsManager.uvrSettings.enableRotateMap.value
    property double     _heading:                   _activeVehicle ? _activeVehicle.heading.value : Number.NaN

    Component {
        id: uvrIndicator

        Rectangle {
            property real _windImageRotat: _root._windImageRotation
            on_WindImageRotatChanged: {
                windImage.rotation = _windImageRotat
            }

            property real _windSpeedVal: _root._windWidgetPostSpeed
            on_WindSpeedValChanged: {
                textInputSpeed.text = _windSpeedVal.toFixed(1)
            }

            implicitWidth:          ScreenTools.defaultFontPixelWidth * 37
            implicitHeight:         ScreenTools.defaultFontPixelWidth * 20
            radius:                 ScreenTools.defaultFontPixelHeight * 0.5
            color:                  qgcPal.window
            border.color:           qgcPal.text

            Item {                  //WindWidget State 1
                id:                 wWidget
                anchors.fill:       parent
                state:              "state2"
                implicitWidth:      ScreenTools.defaultFontPixelWidth * 15
                implicitHeight:     ScreenTools.defaultFontPixelWidth * 8

                QGCLabel {
                    id:                     textWind
                    visible:                wWidget.state == "state1" ? false : true
                    text:                   "Wind"
                    leftPadding:            ScreenTools.comboBoxPadding
                    topPadding:             ScreenTools.comboBoxPadding
                    font.family:            ScreenTools.demiboldFontFamily
                }

                Rectangle {                     //blackCircle + windImage
                    id:                         windImage
                    anchors.left:               parent.left
                    anchors.leftMargin:         wWidget.state == "state1" ? ScreenTools.comboBoxPadding * 2 : (rotationCircle.width-windImage.width)/2
                    anchors.verticalCenter:     parent.verticalCenter
                    height:                     ScreenTools.defaultFontPixelWidth * 9
                    width:                      width
                    radius:                     width * 0.5
                    color:                      qgcPal.window//wWidget.color
                    smooth:                     true
                    Component.onCompleted: {
                        windImage.rotation = _windImageRotation
                        _windImageCompleted = true
                    }
                    Component.onDestruction: {
                        _windImageCompleted = false
                    }
                    onRotationChanged: {
                        if (_windImageCompleted)
                            _windImageRotation = windImage.rotation
                    }
                    Rectangle{
                        anchors.centerIn: parent
                        height:                     ScreenTools.defaultFontPixelWidth * 9
                        width:                      ScreenTools.defaultFontPixelWidth * 9
                        radius:                     width * 0.5
                        color:                      "#00000000"
                        smooth:                     true
                        rotation:                   0
                        Image {
                            id:                         image
                            anchors.centerIn:           parent
                            height:                     parent.height * 0.8
                            width:                      parent.width * 0.8
                            source:                     "qrc:/res/wind.png"
                            sourceSize.width:           100
                            sourceSize.height:          100
                            fillMode:                   Image.PreserveAspectFit
                        }
                    }

                    MouseArea{                      // Mouse area of RotationCircle
                        id:                         rotationArea
                        visible:                    checkBox.checked === true ? false : true
                        anchors.fill:               windImage
                        property real truex:        mouseX - windImage.width/2
                        property real truey:        mouseY - windImage.height/2
                        property real rad:          Math.atan2(truey, truex)
                        property real deg:          parseInt(rad * 180 / Math.PI)

                        onPositionChanged:
                            if (rad<0)
                                windImage.rotation = (windImage.rotation + deg)<=0 ?  windImage.rotation + deg +360: windImage.rotation + deg
                            else
                                windImage.rotation = (windImage.rotation + deg)>=360 ?windImage.rotation + deg -360: windImage.rotation + deg
                    }
                }

                RowLayout {                             // MainContentOfSecondState
                    id:                                 contentState2
                    visible:                            wWidget.state == "state1" ? false : true
                    spacing:                            ScreenTools.comboBoxPadding
                    x:                                  ScreenTools.comboBoxPadding
                    anchors.verticalCenter:             parent.verticalCenter

                    Rectangle {                         // rotationCircleBig
                        id: rotationCircle
                        height:                         ScreenTools.defaultFontPixelWidth * 15
                        width:                          ScreenTools.defaultFontPixelWidth * 15
                        radius:                         width*0.5
                        color:                          "gray"
                        rotation:                       0
                        Text { id: textN; text: "N";color: "white"; anchors.horizontalCenter:  parent.horizontalCenter; y: ((parent.height - windImage.height) / 4) - (textW.contentHeight / 2)}
                        Text { id: textW; text: "W";color: "white"; anchors.verticalCenter:    parent.verticalCenter;   x: ((parent.width - windImage.width) / 4) - (textW.contentWidth / 2)}
                        Text { id: textS; text: "S";color: "white"; anchors.horizontalCenter:  parent.horizontalCenter; y: parent.height - (((parent.height - windImage.height) / 4) + (textE.contentHeight / 2))}
                        Text { id: textE; text: "E";color: "white"; anchors.verticalCenter:    parent.verticalCenter;   x: parent.width - (((parent.width - windImage.width) / 4) + (textE.contentWidth / 2))}
                    }
                    Rectangle {                 // Direction
                        height:                   ScreenTools.defaultFontPixelWidth * 4
                        width:                    ScreenTools.defaultFontPixelWidth * 9
                        radius:                   ScreenTools.comboBoxPadding / 2
                        border.color:             "#808080"

                        QGCLabel {
                            text:                   qsTr("Direction")
                            font.family:            ScreenTools.demiboldFontFamily
                            anchors.bottom:         parent.top
                            anchors.bottomMargin:   ScreenTools.comboBoxPadding / 2
                        }
                        MouseArea {
                            id: mouseAreaInput
                            anchors.fill: parent
                            focus: true
                            Keys.onPressed: {
                                if((event.key === 16777220)||(event.key === Qt.Key_Enter)){
                                    windImage.rotation = textInput.text - 90
                                }
                                textInput.focus = false
                            }
                            TextInput {                 // TEXT INPUT DIRECTION
                                id:                     textInput
                                text:                   (rotationInput.toFixed(0) == "NaN") ? 0 : rotationInput.toFixed(0)
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left:           parent.left
                                anchors.leftMargin:     ScreenTools.comboBoxPadding
                                selectByMouse:          true
                                readOnly:               checkBox.checked ? true : false
                                anchors.rightMargin:    ScreenTools.comboBoxPadding
                                mouseSelectionMode :    TextInput.SelectWords
                                font.family:            ScreenTools.demiboldFontFamily
                                QGCLabel {                  // TEXT °
                                    text:                   " °"
                                    anchors.left:           textInput.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.family:            ScreenTools.demiboldFontFamily
                                    color:                  textInput.color
                                }
                            }
                        }
                    }
                    Rectangle {                   //Speed
                        id:                       speed
                        height:                   ScreenTools.defaultFontPixelWidth * 4
                        width:                    ScreenTools.defaultFontPixelWidth * 9
                        radius:                   ScreenTools.comboBoxPadding / 2
                        border.color:             "#808080"
                        Component.onCompleted: {
                            if (_checkedAPI) {
                                textInputSpeed.text = _windWidgetPostSpeed.toFixed(1)
                            } else {
                                textInputSpeed.text = windSpeedValue.toFixed(1)
                            }
                        }

                        QGCLabel {
                            text:                   qsTr("Speed")
                            font.family:            ScreenTools.demiboldFontFamily
                            anchors.bottom:         parent.top
                            anchors.bottomMargin:   ScreenTools.comboBoxPadding / 2
                        }
                        TextInput {                 // text input Speed
                            id:                     textInputSpeed
                            text:                   windSpeedValue.toFixed(1)
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           parent.left
                            anchors.leftMargin:     ScreenTools.comboBoxPadding
                            selectByMouse:          true
                            anchors.rightMargin:    ScreenTools.comboBoxPadding
                            readOnly:               checkBox.checked ? true : false
                            mouseSelectionMode :    TextInput.SelectWords
                            font.family:            ScreenTools.demiboldFontFamily
                            Keys.onEnterPressed: {
                                textInputSpeed.focus = false
                                windSpeedValue = textInputSpeed.text
                            }
                            Keys.onReturnPressed:{
                                textInputSpeed.focus = false
                                windSpeedValue = textInputSpeed.text
                            }
                            QGCLabel {              //Text m/s
                                id:                        windSpeed
                                text:                      " m/s"
                                font.family:            ScreenTools.demiboldFontFamily
                                anchors.verticalCenter:    textInputSpeed.verticalCenter
                                anchors.left:              textInputSpeed.right
                                color:                     textInputSpeed.color
                            }
                        }
                    }
                }

                QGCCheckBox{
                    id:                         checkBox
                    visible:                    wWidget.state == "state1" ? false : true
                    text:                       "Wind API"
                    textFontFamily:             ScreenTools.demiboldFontFamily
                    anchors.bottom:             parent.bottom
                    anchors.bottomMargin:       ScreenTools.comboBoxPadding * 3
                    anchors.left:               parent.left
                    anchors.leftMargin:         rotationCircle.width + ScreenTools.comboBoxPadding * 2
                    Component.onCompleted: {
                        checkBox.checked = _checkedAPI
                    }
                    onClicked: {  // to do mySlot function when checkBox true
                        _checkedAPI = checkBox.checked
                        if (_checkedAPI) {
                            textInputSpeed.text = _windWidgetPostSpeed.toFixed(1)
                        } else {
                        textInputSpeed.text = windSpeedValue.toFixed(1)
                        }
                        windImage.rotation = _WindWidgetPost.direction - 90
                    }
                }

                states: [
                    State {
                        name: "state1"
                        PropertyChanges{target:windImage; rotation: wWidget.rotationState - 90}
                        ParentChange {target: windImage; parent:wWidget}
                    },
                    State {
                        name: "state2"
                        PropertyChanges { target: wWidget; width : ScreenTools.implicitComboBoxWidth*7+2*ScreenTools.comboBoxPadding; height :  ScreenTools.implicitComboBoxWidth*4;/* opacity : 0.75*/}
                        PropertyChanges{target: windImage;  /*opacity:0.9;*/ rotation: wWidget.rotationState - 90}
                        ParentChange {target: windImage; parent: rotationCircle; width : rotationCircle.width * 0.6; height : rotationCircle.height * 0.6;}
                        ParentChange {target: windSpeed;parent: speed }

                    }
                ]
            }
        }
    }

    Timer{
        id: timer
        interval: QGroundControl.settingsManager.uvrSettings.intervalUpdate.value * 1000
        running: _checkedAPI
        repeat: true
        onTriggered:
        {
            _WindWidgetPost.sendRequest()
        }
    }

    WindWidgetPost {
        id:                     _WindWidgetPost
        onDirectionChanged :    {
            _windImageRotation       = _WindWidgetPost.direction - 90
            _windWidgetPostDirection = _WindWidgetPost.direction
        }
        onSpeedChanged:         {
            _windWidgetPostSpeed     = _WindWidgetPost.speed
        }
        direction:              rotationState
        apiKey:                 _WindWidgetPost.writeApiKey(QGroundControl.settingsManager.uvrSettings.apiKeyProfessional.value)
        latitude:               lat
        lonitude:               lon
    }

    RowLayout {
        id:             uvrIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Image {
            id:                     windIcon
            Layout.preferredHeight: parent.height
            sourceSize.height:      height
            source:                 qgcPal.globalTheme === QGCPalette.Light ? "qrc:/res/windOutdoorTheme.svg" : "qrc:/res/wind.svg"
            fillMode:               Image.PreserveAspectFit
            opacity:                true ? 1 : 0.5
            rotation:               _enableRotateMap ? (_windImageRotation - _heading) : _windImageRotation
            mipmap:                 true
            Layout.alignment:       Qt.AlignVCenter
        }
        QGCLabel {
            text:                   _checkedAPI ? _windWidgetPostSpeed.toFixed(1) + "\nm/s" : windSpeedValue.toFixed(1) + "\nm/s"
            horizontalAlignment:    Text.AlignHCenter
            Layout.alignment:       Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill:   uvrIndicatorRow
        onClicked: {
            mainWindow.showIndicatorPopup(_root, uvrIndicator)
        }
    }
}


