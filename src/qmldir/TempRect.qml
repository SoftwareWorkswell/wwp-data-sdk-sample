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
    // change mode of temp rext = radiometric shows temp, raw signal values
    function changeMode(radiometric)
    {
        if(radiometric)
        {
            tempLabel.visible = tempText.visible = true
        }
        else
        {
            tempLabel.visible = tempText.visible = false

        }
    }

    RowLayout {
        width: parent.width
        height: parent.height /2
        anchors.top: parent.top
        ColumnLayout {
            Layout.fillHeight: parent
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            Text { id: tempLabel; text: "Temperature:"; font.bold: true; color: "black" }
            Text { text: "RAW:"; font.bold: true; color: "black" }
        }
        ColumnLayout {
            Layout.fillHeight: parent
            Layout.preferredWidth: 60
            Layout.alignment: Qt.AlignLeft
            Text { id: tempText; color: "black" }
            Text { id: rawText; color: "black" }
        }
    }
    RowLayout {
        width: parent.width
        height: parent.height /2
        anchors.bottom: parent.bottom
        ColumnLayout {
            Layout.fillHeight: parent
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            Text { text: "X:"; font.bold: true; color: "black" }
            Text { text: "Y:"; font.bold: true; color: "black" }
        }
        ColumnLayout {
            Layout.fillHeight: parent
            Layout.preferredWidth: 60
            Layout.alignment: Qt.AlignLeft
            Layout.margins: 5
            Text { id: xpos; color: "black" }
            Text { id: ypos; color: "black" }
        }
    }
}
