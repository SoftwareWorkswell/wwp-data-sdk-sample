import QtQuick 2.12
import QtQuick.Dialogs 1.3

FileDialog {
    title: "Please choose sequences"
    folder: shortcuts.home
    selectMultiple: true
    nameFilters: ["Thermal sequences (*.wseq *.seq)"]
    onAccepted: {
        _backend.makeFileData(fileUrls);
        neutralize()
    }
    Component.onCompleted: visible = false
}
