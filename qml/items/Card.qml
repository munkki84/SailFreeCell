import QtQuick 2.0
import Sailfish.Silica 1.0
import "Rules.js" as Rules
Rectangle {
    z: 2
    id: card
    state: "stopped"
    property int rank
    property string rankChar
    property int suit
    property string suitChar
    property string suitColor
    property int stack: 0
    property int maxOffset : 50
    property int stackOffset: totalStack < 8 ? maxOffset : maxOffset - (totalStack - 8) //deviceOrientation === Orientation.Portrait ? 40 : 20
    property int maxStack : 1
    property int totalStack : 0
    property Item dragParent
    property Item targetParent
    property PlayField field
    property var acceptedSuits
    property string type : "card"
    property bool wasDropActive
    property bool busy : false
    property var lastMove;
    property var childCard;
    property bool acceptsDrop : false;
    width: deviceOrientation === Orientation.Portrait ? 60 : 74
    height: deviceOrientation === Orientation.Portrait ? 84 : 94
    color: "white"
    border.color: "black"
    border.width: 1
    radius: 10

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 5
    Drag.hotSpot.y: 5


    states: [
        State
        {
            name: "running"
            PropertyChanges { target: card;
                x: targetParent.x + targetParent.parent.x + targetParent.parent.parent.x;
                y: targetParent.y + targetParent.parent.y + targetParent.parent.parent.y }
        }

    ]
    function animate()
    {
        animation.start();
    }
    transitions: [
        Transition {
            from: "stopped"
            to: "running"
            NumberAnimation { id: animation; duration: 250; properties: "x,y"; easing.type: Easing.InOutQuad; }
            onRunningChanged:
            {
                card.busy = animation.running;
                console.log(running);
                if (!running)
                {
                    targetParent.dropCard(card);
                    card.state = "stopped";
                    Qt.animating = Qt.animating - 1;
                    field.movemade(lastMove);

                }
            }
    }

    ]

    function dropCard(Card) {
        Card.parent = card
        card.childCard = Card
        Card.totalStack = card.modifyStack(Card.stack + 1)
        Card.y = card.stackOffset
        Card.stackOffset = card.stackOffset
        Card.anchors.horizontalCenter = card.horizontalCenter

        if (Card.stack === 0) {
            Card.setDrop(true)           
        }
        else
        {
            Card.setTotalStack(Card.childCard, totalStack)
        }
    }
    function setTotalStack(Card, total)
    {
        Card.totalStack = total;
        if (Card.totalStack > 8)
        {
            Card.stackOffset = maxOffset - (total - 8);
            Card.y = maxOffset - (total - 8);
        }
        else
        {
            Card.stackOffset = maxOffset;
            Card.y = maxOffset;
        }
        if (Card.stack !== 0) {
          Card.setTotalStack(Card.childCard, Card.totalStack)
        }
    }

    function removeCard(Card) {
        card.childCard = null

        modifyStack(-(Card.stack + 1))

        dropArea.enabled = true
    }


    function reset()
    {

        dropArea.enabled = true
        stack = 0
    }

    function setDrop(value) {
        dropArea.enabled = value
    }
    function modifyStack(value) {
        var total = 0;

        card.stack = card.stack + value

        if (card.parent.stack !== 'undefined') {
            total = card.parent.modifyStack(value);
        }

        if (card.stack >= card.maxStack) {
            dropArea.enabled = false
        }

        if (card.stack === 0) {
            dragArea.enabled = true
        }

        totalStack = total;
        if (card.totalStack > 8)
        {
            card.stackOffset = maxOffset - (card.totalStack - 8);
            card.y = maxOffset - (card.totalStack - 8);
        }
        else
        {
            card.stackOffset = maxOffset;
            card.y = maxOffset;
        }

        return total
    }

    Text {
        x:4; y:0
        color: "black"
        font.pixelSize: 24
        font.bold: true
        //font.family: "Times"
        text: rankChar
    }
    Text {
        x: card.width - font.pixelSize - 4/*32*/;
        y: 0
        color: suitColor
        font.pixelSize: 24
        //font.family: "Times"
        text: suitChar
    }

    MouseArea {
        id: dragArea
        //anchors.fill: card

        width: parent.width + 2
        height: parent.height
        x: -2; y: 0;

        drag.target: card

        onReleased: {
            var retval = card.Drag.drop()
            if (retval === 0)
            {
                card.parent = dragParent
                card.y = card.parent.stackOffset
                card.anchors.horizontalCenter = card.parent.horizontalCenter
                dropArea.enabled = wasDropActive
            }
            else
            {
                var move = [{moved : card, from : card.dragParent, to : card.parent}]
                field.moves.push(move);
                field.movemade(move)
            }

        }
        onPressed: {
            if (Qt.animating !== 0 || !Rules.canDragCard(card))
            {
                mouse.accepted = false
            }
            else
            {
                toTopLevel()
            }
        }
    }
    function toTopLevel()
    {
        card.anchors.horizontalCenter = undefined
        card.anchors.verticalCenter = undefined

        card.dragParent = card.parent

        var coordX = card.x + card.parent.x
        var coordY = card.y + card.parent.y
        var topLevel = card.parent
        while(topLevel.parent.name === 'undefined' || topLevel.parent.name !== "mainPage")
        {
            topLevel = topLevel.parent
            coordX = coordX + topLevel.x
            coordY = coordY + topLevel.y
        }

        card.parent = topLevel
        card.x = coordX
        card.y = coordY

        wasDropActive = dropArea.enabled
        dropArea.enabled = false
    }

    DropArea
    {
        id: dropArea
        width: parent.width + 2
        height: parent.height
        x: -2; y: 0;

        onDropped: {
            if (acceptsDrop)
            {

                drop.source.dragParent.removeCard(drop.source)
                console.log("drop card")
                dropCard(drop.source)

                drop.accept()
            }

            acceptsDrop = false
        }

        onEntered: {

            if (Rules.canDropOnCard(drag.source, card))
            {
                //drag.accept()
                acceptsDrop = true
            }
            else
            {
                //drag.accepted = false
                acceptsDrop = false
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
                    target: card
                    border.color: "grey"
                }
            }

        ]
    }
}
