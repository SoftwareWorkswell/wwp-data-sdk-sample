import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import Components 1.0

StackLayout {
    function crossesActivated()
    {
        return crossCheckBox.checked;
    }

    Item {
        id: imageTab
        Layout.fillHeight: parent
        Layout.fillWidth: parent
        RowLayout {
            id: labelLayout1
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 60
            ColumnLayout { //Labels
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { text: "Camera name"; color: "black" }
                Label { text: "Camera manufacturer"; color: "black" }
                Label { text: "Camera serial number"; color: "black" }
                Text  { text: ""; font.bold: true }
                Label { text: "File name"; color: "black" }
                Label { text: "Capture time"; color: "black" }
                Label { text: "Resolution"; color: "black" }
                Text  { text: ""; font.bold: true }
                Label { text: "Emissivity"; color: "black" }
                Label { text: "Reflected temp"; color: "black" }
                Label { text: "Atmospheric temp"; color: "black" }
                Label { text: "Extern optic temp"; color: "black" }
                Label { text: "Object distance"; color: "black" }
                Label { text: "Humidity"; color: "black" }
                Label { text: "Extern optic trans"; color: "black" }
                Text  { text: ""; font.bold: true }
                Label { text: "Max Temp"; color: "black" }
                Label { text: "Min Temp"; color: "black" }
                Label { text: "Show mix/max cross"; color: "black" }
            }
            Item { Layout.preferredWidth: 5 }
            ColumnLayout { //Text lines
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { id: cameraName; color: "black"; text: "-" }
                Label { id: cameraManufacturer; color: "black"; text: "-" }
                Label { id: cameraSerialNumber; color: "black"; text: "-" }
                Label { text: "" }
                Label { id: imageName; color: "black"; text: "-"  }
                Label { id: captureTime; color: "black"; text: "-"  }
                Label { id: resolution; color: "black"; text: "-"  }
                Label { text: "" }
                TextInput {
                    id: emissivity; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setEmissivity(emissivity.text)
                    }
                }
                TextInput {
                    id: reflTemp; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setReflectedTemp(reflTemp.text)
                    }
                }
                TextInput {
                    id: atmTemp; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setAtmTemp(atmTemp.text)
                    }
                }
                TextInput {
                    id: externOpticTemp; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setExternOpticTemp(externOpticTemp.text)
                    }
                }

                TextInput {
                    id: objectDistance; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setObjectDistance(objectDistance.text)
                    }
                }

                TextInput {
                    id: humidity; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        _backend.setHumidity(humidity.text)
                    }
                }
                TextInput {
                    id: externOpticTrans; text: "-"
                    selectByMouse: true
                    onAccepted: {
                        console.log("Accepted")
                        _backend.setExternOpticTrans(externOpticTrans.text)
                    }
                }
                Label { text: "" }
                Label { id: minTemp; color: "black"; text: "-"  }
                Label { id: maxTemp; color: "black"; text: "-"  }
                CheckBox{
                    id: crossCheckBox
                    onClicked: _backend.forcePhotoChanged();

                }
            }
            Item { Layout.fillWidth: parent }
        }
    }
    Item {
        id: sequenceTab
        Layout.fillHeight: parent
        Layout.fillWidth: parent
        RowLayout {
            id: labelLayout2
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 60
            ColumnLayout { //Labels
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { text: "Framerate - FPS"; color: "black" }
                Label { text: "Number of Frames:"; color: "black" }
                Label { text: "Duration"; color: "black" }
            }
            Item { Layout.preferredWidth: 5 }
            ColumnLayout { //Text lines
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { id: framerate; color: "black"; text: "-" }
                Label { id: totalframes; color: "black"; text: "-" }
                Label { id: duration; color: "black"; text: "-" }
            }
            Item { Layout.fillWidth: parent }
        }
    }
    Item {
        id:gpsTab
        Layout.fillHeight: parent
        Layout.fillWidth: parent
        RowLayout {
            id: labelLayout3
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 60
            ColumnLayout { //Labels
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { text: "Altitude"; color: "black" }
                Label { text: "Longtitude"; color: "black" }
                Label { text: "Latitude"; color: "black" }
            }
            Item { Layout.preferredWidth: 5 }
            ColumnLayout { //Text lines
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { id: altitude; color: "black"; text: "-" }
                Label { id: longtitude; color: "black"; text: "-" }
                Label { id: latitude; color: "black"; text: "-" }
            }
            Item { Layout.fillWidth: parent }
        }
    }
    Item {
        id: alarmsTab
        Layout.fillHeight: true
        Layout.fillWidth: true
        RowLayout {
            id: labelLayout4
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 60
            ColumnLayout { //Labels
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                Label { text: "Alarm Type"; color: "black" }
                Item { Layout.preferredWidth: 5 }
                Label { id: topValLabel; text: "Value"; color: "black" }
                Item { Layout.preferredWidth: 5 }
                Label { id: lowerValLabel; text: "Lower Value"; color: "black" }
                Item { Layout.preferredWidth: 5 }
                Label { text: "Color"; color: "black" }
            }
            Item { Layout.preferredWidth: 5 }
            ColumnLayout { //Text lines
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop
                ComboBox
                {
                    id: alarmTypeCB
                    model: ["Above", "Below", "Interval", "Inverted Interval"]
                    onCurrentIndexChanged:
                    {
                        if(currentIndex == 0 || currentIndex == 1)
                        {
                            alarmBottomVal.visible =lowerValLabel.visible = false
                            topValLabel.text = "Value"
                        }
                        else
                        {
                            alarmBottomVal.visible =lowerValLabel.visible = true
                            topValLabel.text = "Upper Value"
                        }
                    }
                }
                TextInput
                {
                    id: alarmTopVal; text: "-"
                    selectByMouse: true
                }
                TextInput
                {
                    id: alarmBottomVal; text: "-"
                    selectByMouse: true
                }
                Button
                {
                    text: "Choose"
                    onClicked:
                    {
                        colorDialog.open()
                    }
                }
                Item { Layout.preferredWidth: 5 }
                Button
                {
                    text: "Apply"
                    onClicked:{
                        switch(alarmTypeCB.currentIndex)
                        {
                        case 0:
                            _backend.addAlarmAbove(alarmTopVal.text, colorDialog.color); break;
                        case 1:
                            _backend.addAlarmBelow(alarmTopVal.text, colorDialog.color); break;
                        case 2:
                            _backend.addAlarmInterval(alarmTopVal.text, alarmBottomVal.text, colorDialog.color); break;
                        case 4:
                            _backend.addAlarmInvInterval(alarmTopVal.text, alarmBottomVal.text, colorDialog.color); break;
                        }
                    }
                }
            }
        }
    }
    ColorDialog
    {
        id: colorDialog
    }

    Connections {
        target: _backend
        onPhotoChanged: {
            if(_backend.getPhotoPointer() !== -1) {
                //Set info panel
                cameraName.text = _backend.getCameraName()
                cameraManufacturer.text = _backend.getCameraManufacturer()
                cameraSerialNumber.text = _backend.getCameraSerialNumber()

                imageName.text = _backend.getImageName(list.currentRow)
                captureTime.text = _backend.getCaptureTime()
                resolution.text = _backend.getResolution()

                emissivity.text = _backend.getEmissivity().toFixed(3)
                reflTemp.text = _backend.getReflectedTemp().toFixed(1)
                atmTemp.text = _backend.getAtmTemp().toFixed(1)
                externOpticTemp.text = _backend.getExternOpticTemp().toFixed(1)
                objectDistance.text = _backend.getObjectDistance().toFixed(1)
                humidity.text = _backend.getHumidity().toFixed(3)
                externOpticTrans.text = _backend.getExternOpticTrans().toFixed(1)

                maxTemp.text = _backend.getMaxImageTemp().toFixed(1);
                minTemp.text = _backend.getMinImageTemp().toFixed(1);

                if(_backend.containsGPSData())
                {
                    altitude.text = _backend.getAltitude()
                    longtitude.text = _backend.getLongitude() + " " + String.fromCharCode(_backend.getLongitudeRef())
                    latitude.text = _backend.getLatitude() + " " + String.fromCharCode(_backend.getLatitudeRef())
                }
                else
                {
                    altitude.text = "-";
                    longtitude.text = "-";
                    latitude.text = "-";
                }
                if(_backend.isSequenceLoaded()) {
                    framerate.text = _backend.getSequenceFramerate();
                    totalframes.text = _backend.getSequenceTotalFrames();
                    duration.text = _backend.getSequenceDuration() + " ms";
                } else {
                   clearSequenceParams()
                }
            } else {
                cameraName.text = "-"
                cameraManufacturer.text = "-"
                cameraSerialNumber.text = "-"

                imageName.text = "-"
                captureTime.text = "-"
                resolution.text = "-"

                clearThermalParams()
                clearSequenceParams()
                altitude.text = "-"
                longtitude.text = "-"
                latitude.text = "-"
            }
        }
    }
    function clearThermalParams()
    {
        emissivity.text = "-"
        reflTemp.text = "-"
        atmTemp.text = "-"
        externOpticTemp.text = "-"
        objectDistance.text = "-"
        humidity.text = "-"
        externOpticTrans.text = "-"
        maxTemp.text = "-"
        minTemp.text = "-"
    }
    function clearSequenceParams()
    {
        framerate.text = "-"
        totalframes.text = "-"
        duration.text = "-"
    }

}
