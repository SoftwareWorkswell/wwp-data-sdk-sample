import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4 as Old
import QtQuick.Controls 2.5 as New
import QtQuick.Dialogs 1.2 as DialogsOld
import QtQuick.Dialogs 1.3 as DialogsNew
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import Qt.labs.platform 1.0

import Components 1.0
import "qmldir"

Window {
    id: mainWindow
    visible: true
    height: Screen.height - Screen.height/10
    width: Screen.width
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    title: qsTr("WWP Data SDK - Sample 0.2.0")
    property int infoVisibility: 1
    property bool imageToolTipVisibility: if(1) true;
    property var temperatures: ["50", "40", "30", "20", "10", "0", "-10", "-20", "-30", "-40", "-50"];

    function neutralize() {
        photo.scale = photo.parent.scale
        photo.rotation = 0
        photo.x = photoFrame.width - photo.width
        photo.y = photoFrame.height - photo.height
    }

    function getPhotoCoords() {
        var photoCoords = [photo.sourceSize.width/photo.paintedWidth*dragArea.mouseX,
                           photo.sourceSize.height/photo.paintedHeight*dragArea.mouseY]
        return photoCoords;
    }

    ColumnLayout {
        id:mainLayout
        anchors.fill: parent
        enabled: false
        ////MENU
        RowLayout {
            id: menuBtnLayout
            Layout.fillWidth: parent; Layout.fillHeight: parent
            Layout.alignment: Qt.AlignLeft

            Item { Layout.preferredWidth: 20 }

            Image {
                id: logo
                fillMode: Image.PreserveAspectFit
                Layout.topMargin: 5
                source: "/images/logo_oficiall_cut.jpg"
            }

            Item { Layout.fillWidth: parent }

            New.ComboBox {
                id: paletteBox
                implicitWidth: 200
                model: ["BlueRed", "BWIron",  "BWIron1",
                        "BWRainbow", "BWRainbowHC", "Gradient",
                        "Gray", "Iron", "Iron1", "Natural", "Sepia",
                        "Steps", "Temperature", "WBRGB", "BlackRed",
                        "BWRGB", "Fire", "Rainbow", "RainbowHC"]
                visible: list.rowCount > 0 ? true : false
                onActivated: {
                    _backend.newPalette(paletteBox.currentText)
                    photo.source = "image://_provider/image" + Math.random()
                    palette.source = "image://_provider/custom_palette" + Math.random()
                }
            }

            Item { Layout.preferredWidth: 5 }
            New.Button {
                id:btnInfo
                text: "Info"
                New.ToolTip.visible: hovered
                New.ToolTip.text: "On/Off info visibility"
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    if(infoVisibility == 1) {
                        info.visible = false
                        infoVisibility = 0
                    }
                    else {
                        info.visible = true
                        infoVisibility = 1
                    }
                }
            }
            Item { Layout.preferredWidth: 5 }

            New.Button {
                id: loadButton
                text: "Load Images"
                onClicked: loadMenu.open()

               New.Menu {
                    id: loadMenu
                    New.MenuItem {
                        text: "Files"
                        onTriggered: fileDialog.open()
                    }
                    New.MenuItem {
                        text: "Folder"
                        onTriggered: folderDialog.visible = true
                    }
                }
            }
            Item { Layout.preferredWidth: 5 }
            New.Button {
                id: btnLoadSequences
                text: "Load Sequences"
                Layout.alignment: Qt.AlignCenter
                onClicked: sequenceDialog.visible = true
            }

            Item { Layout.preferredWidth: 10 }
        }

        ////PREVIEW & PHOTOS
        RowLayout {
            Layout.fillWidth: parent; Layout.fillHeight: parent
            Layout.alignment: Qt.AlignCenter

            //INFO PANEL
            ColumnLayout {
                id: info
                Layout.leftMargin: 1
                //TABLE
                MyTableView { id: list;  }

                Rectangle {
                    color: "grey"
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 350
                    Layout.fillHeight: parent

                    MyTabBar { id: tabBar; anchors.fill: parent }
                    MyStackLayout { id: stackLayout; anchors.fill: parent; currentIndex: tabBar.currentIndex }
                }
                //TEMPERATURE RECTANGLE
                TempRect { id: tempRect }
            }
            //SPACER
            Item { Layout.preferredWidth: 5 }
            //PHOTOS
            ColumnLayout {
                id: photoLayout
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                property int draggedItemIndex: -1

                //GRAPHICS
                RowLayout {
                    id: photoNPaletteFrame
                    Rectangle {
                        id: photoFrame
                        clip: true
                        Layout.fillWidth: parent; Layout.fillHeight: parent
                        Layout.alignment: Qt.AlignCenter
                        property int originalPhotoFrameWidth: 0
                        property int originalPhotoFrameHeight: 0
                        Image {
                            id: photo
                            height: photoFrame.height
                            width: photoFrame.width
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignCenter
                            verticalAlignment: Image.AlignCenter
                            smooth: true
                            source: "image://_provider/default_image" + Math.random()

                            z: dragArea.drag.active ||  dragArea.pressed ? 2 : 1

                            property point beginDrag
                            Drag.active: dragArea.drag.active
                            MouseArea {
                                id: dragArea
                                anchors.fill: parent
                                drag.target: parent
                                cursorShape: Qt.CrossCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                hoverEnabled: true
                                enabled: false
                                onPressed: {
                                    photo.beginDrag = Qt.point(photo.x, photo.y);
                                }
                                onPositionChanged: {
                                    //Temp Rect update
                                    var coords = getPhotoCoords()
                                    var raw;
                                    if(_backend.isSourceLoaded())
                                    {
                                        var temp =  (_backend.getPhotoPointer() !== -1) ? _backend.getTemperature(coords[0], coords[1]).toFixed(2) : ""
                                        raw  = (_backend.getPhotoPointer() !== -1) ? _backend.getRawRadiometricValue(coords[0], coords[1]) : ""
                                        tempRect.setParams(temp, raw, coords[0].toFixed(0), coords[1].toFixed(0))
                                    }
                                }
                                onClicked: {
                                    if(mouse.button & Qt.RightButton) {
                                        exportMenu.x = mouseX;
                                        exportMenu.y = mouseY;
                                        exportMenu.open()
                                    }
                                }
                            }
                        }
                        DropArea {
                            anchors.fill: parent
                        }
                        MouseArea {
                            id: zoomArea
                            anchors.fill: parent
                            hoverEnabled: true
                            scrollGestureEnabled: true
                            clip: true
                            property double max: 1.5
                            property double min: 0.5
                            onWheel: {
                                photo.scale += photo.scale * wheel.angleDelta.y / 120 / 10;
                            }
                        }
                        //EXPORT MENU
                        New.Menu {
                            id: exportMenu
                            New.MenuItem {
                                text: qsTr("Export thermal jpeg")
                                onTriggered: {
                                    exportDialog.thermal = true
                                    exportDialog.open()
                                }
                            }
                            New.MenuItem {
                                text: qsTr("Export jpeg")
                                onTriggered: {
                                    exportDialog.thermal = false
                                    exportDialog.open()
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    id: controlPanel
                    //SEQUENCE BUTTONS
                    MySequenceControls { id: sequenceControl; visible: false }
                    //SOURCE BUTTONS
                    MyImageControls {}
                }
            }
            Item { Layout.preferredWidth: 5; Layout.maximumWidth: 10}
            //PALETTE
            ColumnLayout {
                Layout.maximumWidth: 100
                Connections {
                    target: _backend
                    onRangeChanged:
                    {
                        maxTemp.enabled = minTemp.enabled = manual
                        maxTemp.visible = minTemp.visible = manual
                    }
                }

                Old.TextField {
                    id: maxTemp
                    implicitWidth: 50
                    Layout.alignment: Qt.AlignLeft
                    font.pointSize: sclftn.font.pointSize
                    selectByMouse: true
                    textColor: "black"
                    text: temperatures[0]
                    enabled: false
                    visible: false
                    onAccepted: {
                        _backend.setMaxTemperature(maxTemp.text)
                        temperatures = _backend.getTemperatureScale()
                        photo.source = "image://_provider/image" + Math.random()
                        palette.source = "image://_provider/custom_palette" + Math.random()
                    }
                }
                Rectangle {
                    id: paletteFrame
                    Layout.fillHeight: parent
                    Layout.preferredWidth: 60
                    color: "white"
                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            id: tempScale
                            Layout.alignment: Qt.AlignLeft
                            //Layout.rightMargin: 5
                            Layout.fillHeight: parent
                            Layout.preferredWidth: 25
                            ColumnLayout {
                                anchors.fill: parent
                                Text { id: sclftn; text: temperatures[0] }
                                Text { text: temperatures[1] }
                                Text { text: temperatures[2] }
                                Text { text: temperatures[3] }
                                Text { text: temperatures[4] }
                                Text { text: temperatures[5] }
                                Text { text: temperatures[6] }
                                Text { text: temperatures[7] }
                                Text { text: temperatures[8] }
                                Text { text: temperatures[9] }
                                Text { text: temperatures[10] }
                            }
                        }
                        Item { width: 5; Layout.alignment: Qt.AlignCenter }
                        Image {
                            id: palette
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillHeight: parent
                            Layout.preferredWidth: 25
                            source: "image://_provider/default_palette" + Math.random()
                        }
                    }
                }
                Old.TextField {
                    id: minTemp
                    Layout.alignment: Qt.AlignLeft
                    implicitWidth: 50
                    font.pointSize: sclftn.font.pointSize
                    selectByMouse: true
                    textColor: "black"
                    text: temperatures[10]
                    enabled: false
                    visible: false
                    onAccepted: {
                        _backend.setMinTemperature(minTemp.text)
                        temperatures = _backend.getTemperatureScale()
                        photo.source = "image://_provider/image" + Math.random()
                        palette.source = "image://_provider/custom_palette" + Math.random()
                    }
                }
                New.Label {
                    id: unitLabel
                    Layout.alignment: Qt.AlignLeft
                    text: "[ °C ]"
                    color: "black"
                }
                Item { Layout.preferredHeight: 5 }
            }
        }
    }

    //AUTHETIFICATION DIALOG
    AuthDialog {}
    //FILE DIALOG
    MyFileDialog { id: fileDialog }
    //FILE DIALOG
    MySequenceDialog { id: sequenceDialog }
    //FOLDER DIALOG
    MyFolderDialog { id: folderDialog }

    //ERROR DIALOG
    DialogsNew.MessageDialog {
        id: errorDialog
        icon: StandardIcon.Warning
        text: "Added source is not compatible radiometric file"

        //Component.onCompleted: open()
    }

    ///MENU BAR
    MenuBar {
        Menu {
            id: licenses
            title: "Licenses"
            MenuItem {
                text: qsTr("Deactivate")
                onTriggered: {
                    _backend.deactivate()
                    _backend.setAuthMessage("Your license was deactivated succesfully!");
                }
            }
        }
    }


    //EXPORT DIALOG
    DialogsNew.FileDialog {
        id: exportDialog
        folder: shortcuts.home
        selectExisting: false
        selectFolder: false
        selectMultiple: false
        nameFilters: ["Image files (*.jpg *.jpeg)", "All files (*)" ]
        property bool thermal: false
        onAccepted: {
            var path = fileUrl.toString();
            path= Qt.platform.os == "osx" ? path.replace(/^(file:\/{2})/,"") : path.replace(/^(file:\/{3})|(qrc:\/{2})/,"");
            if(thermal)
                _backend.exportThermalImage(path);
            else
                _backend.exportBasicImage(path);
        }
    }

    Connections {
        target: _backend
        onDataChanged: list.model = _backend.qml_names
        onPhotoChanged: {
            // if we want crosses, we need to change id so provider will paint crosses
            photo.source = stackLayout.crossesActivated() ? ("image://_provider/image_painted" + Math.random()) : ("image://_provider/image" + Math.random())
            photoFrame.originalPhotoFrameWidth = photoFrame.width
            photoFrame.originalPhotoFrameHeight = photoFrame.height
            photoFrame.width = info.visible ? photo.paintedWidth : photoFrame.width
            photoFrame.height = info.visible ? photo.paintedHeight : photoFrame.height
            if(_backend.getPhotoPointer() !== -1) {
                temperatures = _backend.getTemperatureScale("c")
                palette.source = "image://_provider/custom_palette" + Math.random()
            } else if(_backend.getPhotoPointer() === -1) {
                temperatures = ["50", "40", "30", "20", "10", "0", "-10", "-20", "-30", "-40", "-50"]
                palette.source = "image://_provider/default_palette" + Math.random()
            }
            //if(!_backend.isSequenceLoaded())
                //neutralize()

            paletteBox.visible = list.rowCount > 0 ? true : false
            dragArea.enabled = _backend.isSourceLoaded();
            sequenceControl.visible = _backend.isSequenceLoaded();

            //Temp Rect update
            var coords = getPhotoCoords()
            var raw;
            if(_backend.isSourceLoaded())
            {
                unitLabel.text = "[ °C ]"
                var temp =  (_backend.getPhotoPointer() !== -1) ? _backend.getTemperature(coords[0], coords[1]).toFixed(2) : ""
                raw  = (_backend.getPhotoPointer() !== -1) ? _backend.getRawRadiometricValue(coords[0], coords[1]) : ""
                tempRect.setParams(temp, raw, coords[0].toFixed(0), coords[1].toFixed(0))
            }
        }
        onPhotoDeleted:
        {
            photoFrame.width = photoFrame.originalPhotoFrameWidth;
            photoFrame.height = photoFrame.originalPhotoFrameHeight;
        }
        onImageWithPaletteLoaded: {
            if(_backend.getPhotoPointer() !== -1) {
                if(paletteName.includes(".plt"))
                    paletteName = paletteName.slice(0, paletteName.indexOf("."));
                paletteBox.currentIndex = paletteBox.model.indexOf(paletteName);
            }
        }
        onSourceError: errorDialog.open()
        onActivated: mainLayout.enabled = true
    }
}
