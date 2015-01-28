import QtQuick 2.0
import Sailfish.Silica 1.0
import "Rules.js" as Rules
Rectangle {
    id: dropRect
    property int stack: 0
    property int stackOffset: 0
    property int maxStack : 1
    property string suitChar
    property var acceptedSuits : [1,2,3,4]
    property string type
    property bool acceptsDrop : false;
    z: 1
    width: deviceOrientation === Orientation.Portrait ? 62 : 76
    height: deviceOrientation === Orientation.Portrait ? 86 : 96

    color: Theme.rgba(Theme.secondaryHighlightColor, 0.5)//"#800000FF"
    border.color: "black"
    border.width: 1


    radius: 10

    states: [
        State {
            when: stack < maxStack
            PropertyChanges {
                target: dropArea
                enabled: true
            }
        }
    ]


    function reset()
    {
        dropArea.enabled = true
        stack = 0

    }

    function dropCard(Card)
    {
        if (type != "suitcell")
        {
            if (stack === 0)
            {
                Qt.freeCells = Qt.freeCells - 1
                //console.log(Qt.freeCells)
            }
        }

        Card.parent = dropRect
        Card.anchors.verticalCenter = dropRect.verticalCenter
        Card.anchors.horizontalCenter = dropRect.horizontalCenter
        Card.y = 0

        Card.totalStack = dropRect.modifyStack(Card.stack + 1)

        if (type === "suitcell")
        {
            Card.setDrop(false)
        }
        else if (type === "cell")
        {
            Card.setDrop(false)
        }
        else
        {
            if (Card.stack === 0)
            {
                Card.setDrop(true)
            }
        }
    }
    function removeCard(Card)
    {
        modifyStack(-(Card.stack + 1))

        if (type != "suitcell")
        {
            Qt.freeCells = Qt.freeCells + 1
            //console.log(Qt.freeCells)
        }
    }
    function modifyStack(value)
    {
        dropRect.stack = dropRect.stack + value
        if (dropRect.stack >= dropRect.maxStack) {
            dropArea.enabled = false
        }
        return stack;
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "black"
        font.pixelSize: 48
        opacity: 0.5
        text: suitChar
    }

    DropArea {
        id: dropArea
        anchors.fill: parent

        onDropped: {
            if (acceptsDrop)
            {
                drop.source.dragParent.removeCard(drop.source)

                //console.log("drop 1")
                dropCard(drop.source)

                drop.accept()
            }
            acceptsDrop = false
        }

        onEntered: {

            if (Rules.canDropOnCell(drag.source, dropRect))
            {
                acceptsDrop = true
                //drag.accept()
            }
            else
            {
                acceptsDrop = false
                //drag.accepted = false
            }

        }
        onExited:
        {
            acceptsDrop = false
        }
        states: [
            State {
                when: acceptsDrop//dropArea.containsDrag
                PropertyChanges {
                    target: dropRect
                    border.color: "white"
                }
            }

        ]

    }

}
