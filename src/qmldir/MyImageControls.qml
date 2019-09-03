import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import Components 1.0

RowLayout {
    Layout.fillWidth: parent; Layout.fillHeight: parent
    Layout.alignment: Qt.AlignCenter

    function setRangeButtonText()
    {
        rangeButton.text = "M"
    }

    Item { Layout.fillWidth: parent }

    Button {
        id:btnBack
        icon.source: "/images/arrow_left.png"
        ToolTip.visible: hovered
        ToolTip.text: "Previous image"
        Layout.alignment: Qt.AlignCenter
        onClicked: {
            _backend.photoBack()
            neutralize()
            if((0 <= _backend.getPhotoPointer()) && (_backend.getPhotoPointer() < list.rowCount)) {
                list.selection.select(_backend.getPhotoPointer())
                list.selection.deselect(_backend.getPhotoPointer() + 1)
            }
        }
    }

    Button { //Button - Next
        id:btnNext
        icon.source: "/images/arrow_right.png"
        ToolTip.visible: hovered
        ToolTip.text: "Next image"
        Layout.alignment: Qt.AlignCenter
        onClicked: {
            _backend.photoNext();
            neutralize()
            if((0 <= _backend.getPhotoPointer()) && (_backend.getPhotoPointer() < list.rowCount)) {
                list.selection.select(_backend.getPhotoPointer())
                list.selection.deselect(_backend.getPhotoPointer() - 1)
            }
        }
    }

    Button {
        id:btnRotateLeft
        icon.source: "/images/arrow_rotate_left.png"
        ToolTip.visible: hovered
        ToolTip.text: "Rotate left"
        Layout.alignment: Qt.AlignCenter
        onClicked: photo.rotation -= 90
    }

    Button {
        id:btnRotateRight
        icon.source: "/images/arrow_rotate_right.png"
        ToolTip.visible: hovered
        ToolTip.text: "Rotate right"
        Layout.alignment: Qt.AlignCenter
        onClicked: photo.rotation += 90
    }

    Button {
        id:btnErase
        icon.source: "/images/erase.png"
        ToolTip.visible: hovered
        ToolTip.text: "Erase all changes"
        Layout.alignment: Qt.AlignCenter
        onClicked: neutralize()
    }

    Button {
        id: rangeButton
        text: "M"
        ToolTip.visible: hovered
        ToolTip.text: "Automatic/Manual range"
        Layout.alignment: Qt.AlignCenter
        property bool manual: false
        onClicked: {
            if(!_backend.isSourceLoaded())
                return;
            manual = !manual
            if(manual) {
                _backend.setManualRangeOn();
                text = "A"
            }
            else {
                _backend.setManualRangeOff();
                text = "M"
            }
        }
    }

    Item { Layout.fillWidth: parent }
}
