import QtQuick 2.12
import QtQuick.Dialogs 1.3

FileDialog {
    title: "Please choose images"
    folder: shortcuts.home
    selectMultiple: true
    nameFilters: ["Image files (*.jpg *.jpeg)"]
    Component.onCompleted: visible = false
    onAccepted: {
        _backend.makeFileData(fileUrls);
        neutralize()
    }
}
