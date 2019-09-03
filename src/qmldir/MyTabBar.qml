import QtQuick 2.12
import QtQuick.Controls 2.4

TabBar {
    TabButton {
        text: "Source Info"
        implicitWidth: 130
    }
    TabButton {
        id: theLongest
        text: "Sequence Info"
        width: 140
    }
    TabButton {
        text: "GPS Info"
        width: 90
    }
}
