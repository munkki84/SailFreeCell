import QtQuick 2.0
import Sailfish.Silica 1.0
import "Rules.js" as Rules
Rectangle {
    z: 2
    id: card
    state: "stopped"
    property int dbId
    property int rank
    property string rankChar
    property int suit
    property string suitChar
    property string suitColor
    property int stack: 0
    property int maxOffset : 50
    property int stackNarrowStart: deviceOrientation === Orientation.Portrait ? 8 : 6
    property double narrowMultiplier:  deviceOrientation === Orientation.Portrait ? 1 : 1.5
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
    property var childCard : null;
    property bool acceptsDrop : false;
    property var hotSpots : deviceOrientation === Orientation.Portrait ?
                                [{x: 5, y: 5}, {x: 55, y: 5}]://, {x: 5, y: 42 }, {x: 55, y: 42}] :
                                [{x: 5, y: 5}, {x: 69, y: 5}]//, {x: 5, y: 47 }, {x: 69, y: 47}]
    property bool dropEnabled : dropArea.enabled
    width: deviceOrientation === Orientation.Portrait ? 60 : 74
    height: deviceOrientation === Orientation.Portrait ? 84 : 94
    color: "white"
    border.color: "black"
    border.width: 1

    antialiasing: true
    radius: 10

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: 5
    Drag.hotSpot.y: 5

    onXChanged: {
        if (Drag.active)
        {
            hotspotHack();
        }
    }
    onYChanged: {
        if (Drag.active)
        {
            hotspotHack();
        }
    }

    property var dropCandidates: []

    //
    // hotspotHack()
    // hack to implement multiple hotspots, function first finds all possible cards or cells
    // that each hotspot can drop to. Then hotspot that is closest to a droppable item is selected.
    // Effectively dragged card will be dropped on a card or cell that dragged card is covering the most.
    //
    function hotspotHack(){

        dropCandidates = []

        for (var i = 0; i < hotSpots.length; i++)
        {
            var collidingItems = field.getCollidingDroppableItems(card, hotSpots[i].x, hotSpots[i].y);

            for (var j = 0; j < collidingItems.length; j++)
            {
                var item = collidingItems[j]
                if (item.item.type === "card")
                {
                    if (Rules.canDropOnCard(card, item.item))
                    {
                         dropCandidates.push({spot: hotSpots[i], distance: item.distance});
                    }
                }
                else
                {
                    if (Rules.canDropOnCell(card, item.item))
                    {
                        dropCandidates.push({spot: hotSpots[i], distance: item.distance});
                    }
                }
            }
        }

        var bestSpot = null
        for (var k = 0; k < dropCandidates.length; k++)
        {
            if (bestSpot === null)
            {
                bestSpot = dropCandidates[k]
            }
            else
            {
                if (bestSpot.distance > dropCandidates[k].distance)
                {
                    bestSpot = dropCandidates[k]
                }
            }

        }

        if (bestSpot !== null)
        {
            Drag.hotSpot.x = bestSpot.spot.x
            Drag.hotSpot.y = bestSpot.spot.y
        }
    }


    states: [
        State
        {
            name: "running"
            PropertyChanges { target: card;
                x: targetParent.mapToRoot().x
                y: targetParent.mapToRoot().y + targetParent.maxOffset
            }
        }
    ]

    StateGroup
    {
        states: [
            State {
                when: deviceOrientation === Orientation.Portrait && card.parent.type === "card"
                PropertyChanges {
                    target: card;
                    y: calcOffset()
                }
            },
            State {
                when: deviceOrientation === Orientation.Landscape && card.parent.type === "card"
                PropertyChanges {
                    target: card;
                    y: calcOffset()
                }
            }
        ]
    }


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
                    card.state = "stopped";
                    targetParent.dropCard(card);

                    Qt.animating = Qt.animating - 1;
                    field.movemade(lastMove);
                }
            }
        }
    ]

    function calcOffset()
    {
        if (card.parent.type === "card")
        {
            return totalStack < stackNarrowStart ? maxOffset :
                                                   maxOffset - (narrowMultiplier * totalStack - stackNarrowStart);
        }
        return 0;
    }

    function dropCard(Card) {
        Card.parent = card
        card.childCard = Card
        card.modifyStack(Card.stack + 1)
        Card.setTotalStack(totalStack)
        Card.y = Card.calcOffset()
        Card.anchors.horizontalCenter = card.horizontalCenter

        if (Card.stack === 0) {
            Card.setDrop(true)           
        }
    }

    function setTotalStack(total)
    {
        card.totalStack = total;
        card.y = card.calcOffset();
        if (card.stack !== 0 && card.childCard !== null) {
          card.childCard.setTotalStack(total)
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
        childCard = null
        parent = field
    }

    function setDrop(value) {
        dropArea.enabled = value
    }

    function modifyStack(value) {
        var total = 0;

        card.stack = card.stack + value

        if (card.parent.stack !== 'undefined' && card.parent.type !== 'playfield') {
            total = card.parent.modifyStack(value);
        }

        if (card.stack >= card.maxStack) {
            dropArea.enabled = false
        }

        totalStack = total;
        if (card.stack === 0) {
            dragArea.enabled = true
        }

        card.y = calcOffset();
        return total;
    }

    Text {
        id: rankText
        x:4; y:0
        color: "black"
        font.pixelSize: 24
        font.bold: true
        text: rankChar
    }
    Text {
        id: suitText
        x: card.width - font.pixelSize - 4/*32*/;
        y: 0
        color: suitColor
        font.pixelSize: 24
        text: suitChar
    }

    MouseArea {
        id: dragArea

        width: parent.width + 4
        height: parent.height
        x: -2;
        y: 0;
        drag.target: card

        property real lastClick: Date.now()

        onReleased: {
            var retval = card.Drag.drop()
            if (retval === 0)
            {
                card.parent = dragParent
                card.y = calcOffset()
                card.anchors.horizontalCenter = card.parent.horizontalCenter
                dropArea.enabled = wasDropActive
            }
            else
            {
                var move = [{moved : card, from : card.dragParent, to : card.parent}]
                field.moves.push(move);
                field.movemade(move)

                if (acceptsDrop)
                {
                    acceptsDrop = false
                    field.selectedCard = null
                }
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

        onClicked:
        {
            // this card was already clicked, check are we trying to double click
            if (Date.now() - lastClick < 300)
            {
                console.log("dclick")
                // doubleclick: try to move this card to suit cell
                var move = [];
                if (field.tryMoveToSuitCell(card, move, false))
                {
                    field.moves.push(move);
                    field.movemade(move);
                }
                acceptsDrop = false;
                field.selectedCard = null;
                return;
            }

            lastClick = Date.now()

            // Check if the card was already clicked
            if (!acceptsDrop)
            {
                // card was not clicked, check if there is selected card
                if (field.selectedCard !== null)
                {
                    // deselect selected card
                    field.selectedCard.acceptsDrop = false;

                    // check is it possible to drop selected card on this card
                    if (Rules.canDragCard(field.selectedCard) && Rules.canDropOnCard(field.selectedCard, card) && dropArea.enabled)
                    {
                        // make animated move
                        var move = [{moved : field.selectedCard, from : field.selectedCard.parent, to : card}]
                        field.moves.push(move);
                        field.makeAnimatedMove(move, move[0]);
                        field.selectedCard = null;
                    }
                    else
                    {
                        // cannot drop, set this card as selected
                        field.selectedCard = card;
                        acceptsDrop = true;
                    }
                }
                else
                {
                    // set this card selected
                    field.selectedCard = card;
                    acceptsDrop = true;
                }
            }
            else
            {
                // deselect this card
                acceptsDrop = false;
                field.selectedCard = null;
            }
        }
    }

    function toTopLevel()
    {
        card.anchors.horizontalCenter = undefined
        card.anchors.verticalCenter = undefined

        card.dragParent = card.parent

        var mapped = mapToRoot()
        card.parent = mapped.item
        card.x = mapped.x
        card.y = mapped.y

        wasDropActive = dropArea.enabled
        dropArea.enabled = false
    }

    function mapToRoot()
    {
        var coordX = card.x + card.parent.x
        var coordY = card.y + card.parent.y
        var root = card.parent
        while(root.parent.name === 'undefined' || root.parent.name !== "mainPage")
        {
            root = root.parent
            coordX = coordX + root.x
            coordY = coordY + root.y
        }
        var retval = {item : root, x : coordX, y : coordY};
        return retval
    }

    DropArea
    {
        id: dropArea
        width: //parent.width * 2 - 10
               parent.width + 4
        height: //parent.height * 2 - 10
                parent.height
        x: //-parent.width / 2 + 5
           -2;
        y: //-parent.height / 2 + 5
           0;

        onDropped: {
            if (acceptsDrop)
            {

                drop.source.parent = drop.source.dragParent

                field.makeMove(drop.source, card, true)

                drop.accept()
            }

            acceptsDrop = false
        }

        onEntered: {
            //console.log(card.rankChar + card.suitChar)
            if (Rules.canDropOnCard(drag.source, card))
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

                if (typeof(field.droppableItems[card.dbId]) === "undefined")
                {
                    field.addToDroppableItems(card)

                }

            }
            else
            {
                if (typeof(field.droppableItems[card.dbId]) !== "undefined")
                {
                    field.removeFromDroppableItems(card);

                }
            }
        }

        states: [
            State {
                when: acceptsDrop//dropArea.containsDrag
                PropertyChanges {
                    target: card
                    color: "lightGray"
                    //border.color: "lightBlue"
                    //border.width: 3
                }
            }

        ]
    }
}
