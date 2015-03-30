import QtQuick 2.0
import Sailfish.Silica 1.0
import "Rules.js" as Rules
Rectangle {
    id: dropRect
    property int dbId
    property int stack: 0
    property int totalStack: 0
    property int maxOffset: 0
    property int maxStack : 1
    property string suitChar
    property var acceptedSuits : [1,2,3,4]
    property string type
    property bool acceptsDrop : false;
    property var childCard;
    property bool dropEnabled : dropArea.enabled
    z: 1
    width: deviceOrientation === Orientation.Portrait ? 62 : 76
    height: deviceOrientation === Orientation.Portrait ? 86 : 96

    color: Theme.rgba(Theme.secondaryHighlightColor, 0.5)//"#800000FF"
    border.color: "black"
    border.width: 1
    radius: 10

    StateGroup {
        states: [
            State {
                when: stack < maxStack
                PropertyChanges {
                    target: dropArea
                    enabled: true
                }
            }
        ]
    }

    function reset()
    {
        dropArea.enabled = true
        stack = 0
        childCard = null
    }

    function calcOffset()
    {
        return 0;
    }

    function dropCard(Card)
    {
        if (type != "suitcell")
        {
            if (stack === 0)
            {
                Qt.freeCells = Qt.freeCells - 1
            }
        }

        Card.parent = dropRect
        Card.anchors.verticalCenter = dropRect.verticalCenter
        Card.anchors.horizontalCenter = dropRect.horizontalCenter
        Card.y = 0
        dropRect.modifyStack(Card.stack + 1)

        Card.setTotalStack(stack)

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

    function mapToRoot()
    {
        var coordX = dropRect.x + dropRect.parent.x
        var coordY = dropRect.y + dropRect.parent.y
        var root = dropRect.parent
        while(root.parent.name === 'undefined' || root.parent.name !== "mainPage")
        {
            root = root.parent
            coordX = coordX + root.x
            coordY = coordY + root.y
        }
        var retval = {item : root, x : coordX, y : coordY};
        return retval
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
                drop.source.parent = drop.source.dragParent
                field.makeMove(drop.source, dropRect, true)
                drop.accept()
            }
            acceptsDrop = false
        }

        onEntered: {

            if (Rules.canDropOnCell(drag.source, dropRect))
            {
                acceptsDrop = true
            }
            else
            {
                acceptsDrop = false
            }

        }
        onExited:
        {
            acceptsDrop = false
        }
        onEnabledChanged:
        {
            if (dropArea.enabled)
            {

                if (typeof(dropRect.parent.droppableItems[dropRect.dbId]) === "undefined")
                {
                    dropRect.parent.addToDroppableItems(dropRect)

                }

            }
            else
            {
                if (typeof(dropRect.parent.droppableItems[dropRect.dbId]) !== "undefined")
                {
                    dropRect.parent.removeFromDroppableItems(dropRect);

                }
            }
        }
        states: [
            State {
                when: acceptsDrop
                PropertyChanges {
                    target: dropRect
                    border.color: "white"
                }
            }

        ]

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked:
        {
            if (dropRect.parent.selectedCard !== null)
            {
                if (Rules.canDropOnCell(dropRect.parent.selectedCard, dropRect) && dropArea.enabled)
                {
                    var move = [{moved : dropRect.parent.selectedCard, from : dropRect.parent.selectedCard.parent, to : dropRect}]
                    dropRect.parent.moves.push(move);
                    dropRect.parent.makeAnimatedMove(move, move[0]);
                }
                dropRect.parent.selectedCard.acceptsDrop = false;
                dropRect.parent.selectedCard = null;
            }
        }
    }
}
