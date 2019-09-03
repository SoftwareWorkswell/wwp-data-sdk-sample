import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.5 as New

import Components 1.0

TableView {
    Layout.alignment: Qt.AlignCenter
    Layout.preferredWidth: 350
    Layout.preferredHeight: 200
    alternatingRowColors: false
    backgroundVisible: false
    headerDelegate: Rectangle {
        height: textItem.implicitHeight * 1.2
        width: textItem.implicitWidth
        color: "white"
        Text {
            id: textItem
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: styleData.textAlignment
            anchors.leftMargin: 12
            text: styleData.value
            elide: Text.ElideRight
            color: textColor
            renderType: Text.NativeRendering
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            anchors.topMargin: 1
            width: 1
            color: "#ccc"
        }
    }

    onCurrentRowChanged: {
        if(_backend.getPhotoPointer() !== -1) {
            if(_backend.isSequenceLoaded()) _backend.pauseSequence()
            _backend.setPhotoPointer(list.currentRow);
        }
    }
    TableViewColumn {
        id: nameCol
        title: "Names"
        role: "value"
        width: 260
        delegate:
        Text {
            id: tableText
            text: styleData.value === "undefined" ? "" : styleData.value
        }
    }
    TableViewColumn {
        id: btnDeleteCol
        title: qsTr("Delete")
        width:  70
        delegate:
        New.Button {
            text: "Delete"
            onClicked: {
                _backend.deletePhoto(list.currentRow)
                list.selection.select(_backend.getPhotoPointer())
                list.selection.deselect(_backend.getPhotoPointer() + 1)
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: { if(list.rowCount > 0)
            if (mouse.button === Qt.RightButton)
                contextTableMenu.popup()
        }
        Menu {
            id: contextTableMenu
            MenuItem {
                text: "Delete all"
                onTriggered: { console.log("Deleting all request"); _backend.deleteAll()}
            }
        }
    }
}
