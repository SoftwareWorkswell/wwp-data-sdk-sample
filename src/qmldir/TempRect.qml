import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle {
    Layout.preferredHeight: 80
    Layout.preferredWidth: parent.width / 2
    Layout.margins: 10
    color: "white"
    function setParams(temp, raw, x, y) {
        tempText.text = temp + "°C";
        rawText.text = raw
        xpos.text = x
        ypos.text = y
    }
    RowLayout {
        width: parent.width
        height: parent.height /2
        anchors.top: parent.top
        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth:  true
            Text { text: "X coordinate:"; font.bold: true; color: "black" }
            Text { text: "Y cooodinate:"; font.bold: true; color: "black" }
        }
        Item { Layout.preferredWidth: 50 }
        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth:  true
            Text { id: xpos; color: "black" }
            Text { id: ypos; color: "black" }
        }
    }

    RowLayout {
        width: parent.width
        height: parent.height /2
        anchors.bottom: parent.bottom
        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth:  true
            Text { id: tempLabel; text: "Temperature:"; font.bold: true; color: "black" }
            Text { text: "Radiometric value:"; font.bold: true; color: "black" }

        }
        Item { Layout.preferredWidth: 40 }
        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.fillWidth:  true
            Layout.alignment: Qt.AlignLeft
            Text { id: tempText; color: "black" }
            Text { id: rawText; color: "black" }
        }
    }
}
