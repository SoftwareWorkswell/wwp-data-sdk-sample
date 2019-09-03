import QtQuick 2.12
import QtQuick.Dialogs 1.3

FileDialog {
    title: "Please choose folder"
    folder: shortcuts.home
    selectFolder: true
    Component.onCompleted: visible = false
    onAccepted: {
        _backend.makeFolderData(fileUrls)
        neutralize()
    }
}
