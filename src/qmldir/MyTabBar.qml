import QtQuick 2.12
import QtQuick.Controls 2.4

TabBar {
    TabButton {
        text: "Info"
        implicitWidth: 70
    }
    TabButton {
        id: theLongest
        text: "Sequence Info"
        width: 140
    }
    TabButton {
        text: "GPS"
        width: 60
    }
    TabButton {
        text: "Alarm"
        width: 90
    }
}
