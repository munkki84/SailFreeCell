import QtQuick 2.0
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
    property int stackOffset: 40
    property int maxStack : 1
    property Item dragParent
    property Item targetParent
    property PlayField field
    property var acceptedSuits
    property string type : "card"
    property bool wasDropActive
    property bool busy : false
    property var lastMove;
    property var childCard;
    //property bool animate : false
    width: 60
    height: 84
    color: "white"
    border.color: "black"
    border.width: 1
    radius: 10

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 5
    Drag.hotSpot.y: 5

//    NumberAnimation { id: animate; properties: "x,y"; easing.type: Easing.InOutQuad;
//                 onRunningChanged: { card.busy = running }}

//    states: State {
//            name: "autoMoved"; when: animate
//            //PropertyChanges { target: card; x: targetParent.x; y: targetParent.y }
//        PropertyChanges { target: card; x: targetParent.x; y: targetParent.y }
//    }

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
//        ParentAnimation {
            NumberAnimation { id: animation; duration: 250; properties: "x,y"; easing.type: Easing.InOutQuad; }
//        }
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
        Card.y = card.stackOffset
        Card.anchors.horizontalCenter = card.horizontalCenter

        card.modifyStack(Card.stack + 1)

        if (Card.stack === 0) {
            Card.setDrop(true)           
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
        card.stack = card.stack + value

        if (card.parent.stack !== 'undefined') {
            card.parent.modifyStack(value);
        }

        if (card.stack >= card.maxStack) {
            dropArea.enabled = false
        }

        if (card.stack === 0) {
            dragArea.enabled = true
        }
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
        x:32; y:0
        color: suitColor
        font.pixelSize: 24
        //font.family: "Times"
        text: suitChar
    }

    MouseArea {
        id: dragArea
        anchors.fill: card

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
        while(topLevel.parent) {
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
        width: parent.width
        height: parent.height
        x: 0; y: 0;

        onDropped: {
            drop.source.dragParent.removeCard(drop.source)
            console.log("drop card")
            dropCard(drop.source)

            drop.accept()
        }

        onEntered: {

            if (Rules.canDropOnCard(drag.source, card))
            {
                drag.accept()
            }
            else
            {
                drag.accepted = false
            }
        }
        states: [
            State {
                when: dropArea.containsDrag
                PropertyChanges {
                    target: card
                    border.color: "grey"
                }
            }

        ]
    }
}
