import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.5 as New
import QtQuick.Dialogs 1.3 as DialogsNew
import QtQuick.Dialogs 1.2 as DialogsOld
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import Qt.labs.platform 1.0

New.Dialog {
    id: authDialog
    anchors.centerIn: parent
    height: 300
    width: 400
    // called after item is initialized
    Component.onCompleted:
    {
        visible = (!_backend.authentification()) ? true : false
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.centerIn: parent
        Text { Layout.alignment: Qt.AlignCenter; text: "<b>Authentification</b>";  }
        Text { id: message; Layout.alignment: Qt.AlignLeft; text: _backend.getAuthMessage() }
        New.TextField {
            id: serialNumber
            Layout.fillWidth: parent
            selectByMouse: true
            placeholderText: "Enter serial number"
            color: "black"
        }
        RowLayout {
            Layout.alignment: Qt.AlignBottom
            New.Button { id: btnCancel; text: "Cancel"; onClicked: Qt.quit() }
            Item { Layout.fillWidth: parent }
            New.Button {
                id: btnDialogOK
                text: "OK"
                visible: false
                onClicked: authDialog.visible = false
            }
            Item { Layout.fillWidth: parent }
            New.Button {
                id: btnActivate
                text: "Activate"
                onClicked: {
                    console.log("User input: " + serialNumber.text)
                    _backend.setAuthKey(serialNumber.text);
                    _backend.activate()
                }
            }
        }
    }
    onClosed: if(_backend.authentification()) false; else authDialog.open()
    Connections{
        target: _backend
        onMessageChanged: message.text = _backend.getAuthMessage()
        onActivated: {
            btnCancel.visible = false
            btnActivate.visible = false
            btnDialogOK.visible = true
        }
        onDeactivated: {
            authDialog.visible = true
            btnCancel.visible = true
            btnActivate.visible = true
            btnDialogOK.visible = false
        }
    }
}
