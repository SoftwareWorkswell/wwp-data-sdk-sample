import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

ColumnLayout {
    Layout.alignment: Qt.AlignCenter

    RowLayout {
        id: sliderLayout
        Layout.alignment: Qt.AlignCenter

        Label {
            id: durationLabel0
            Layout.preferredWidth: 50
            text: "00:00:00"
        }
        Item { Layout.preferredWidth: 10 }
        Slider {
            id: sequenceSlider
            Layout.preferredWidth: 500
            property int duration: 0
            property int frames: 0
            live: false
            onValueChanged:
            {
                if(value == 1)
                    _backend.setSequenceFrame(frames-1)
                if(!pressed)
                    return;
                _backend.setSequenceFrame(value * frames)
            }
        }
        Item { Layout.preferredWidth: 10 }
        Label {
            id: durationLabel
            Layout.preferredWidth: 50
            text: "00:00:00"
        }

    }
    RowLayout {
        Layout.alignment: Qt.AlignCenter
        Button {
            id:buttonFrameBack
            ToolTip.visible: hovered
            ToolTip.text: "Previous frame"
            icon.source: "/images/video_rewind.png"
            onClicked: _backend.prevSequenceFrame();
        }
        Button {
            id:buttonPlay
            ToolTip.visible: hovered
            ToolTip.text: "Play sequence"
            icon.source: "/images/video_play.png"
            onClicked: _backend.playSequence();
        }
        Button {
            id: buttonVideoPause
            ToolTip.visible: hovered
            ToolTip.text: "Pause sequence"
            icon.source: "/images/video_pause.png"
            onClicked: _backend.pauseSequence();
        }
        Button {
            id: buttonVideoForward
            ToolTip.visible: hovered
            ToolTip.text: "Next frame"
            icon.source: "/images/video_forward.png"
            onClicked: _backend.nextSequenceFrame();
        }
    }

    Connections {
        target: _backend
        onPhotoChanged: {
            if(!_backend.isSequenceLoaded())
                return;
            durationLabel0.text = _backend.getCurrentSequenceTime();
            sequenceSlider.value = _backend.getCurrentSequenceTimeMS()/sequenceSlider.duration;
        }
        onSequenceLoaded: {
            if(!_backend.isSequenceLoaded())
                return;
            durationLabel0.text = "00:00:00";
            durationLabel.text = (_backend.getTotalSequenceTime());
            sequenceSlider.duration = _backend.getSequenceDuration();
            sequenceSlider.frames = _backend.getSequenceTotalFrames();
        }
    }
}
