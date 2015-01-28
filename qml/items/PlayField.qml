import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id : playfield
    width : 470; height: 400
    property bool canAutoMove : false
    property string type: "playfield"
    property int smallGap: 2
    property int bigGap: 4
    property int cellGap: 20
    property int landCellsX : 570
    property int landCellsY : 12//140
    property int landFieldsY : 12
    property int landFieldsX : 82
    property int portCellsX : 12
    property int portCellsY : 0

    Cell {
        id: cell1
        stack: 0
        type: "cell"
        x: deviceOrientation === Orientation.Portrait ? portCellsX : field8.x + field8.width + 60
        y: deviceOrientation === Orientation.Portrait ? portCellsY  : landCellsY
    }

    Cell {
        id: cell2
        stack: 0
        type: "cell"
        x: deviceOrientation === Orientation.Portrait ? cell1.x + cell1.width + smallGap/*74*/ : cell1.x
        y: deviceOrientation === Orientation.Portrait ? portCellsY : cell1.y + cell1.height + smallGap
    }
    Cell {
        id: cell3
        stack: 0
        type: "cell"
        x: deviceOrientation === Orientation.Portrait ? cell2.x + cell2.width + smallGap/*138*/ : cell1.x
        y: deviceOrientation === Orientation.Portrait ? portCellsY : cell2.y + cell2.height + smallGap
    }
    Cell {
        id: cell4
        stack: 0
        type: "cell"
        x: deviceOrientation === Orientation.Portrait ? cell3.x + cell3.width + smallGap/*202*/ : cell1.x
        y: deviceOrientation === Orientation.Portrait ? portCellsY : cell3.y + cell3.height + smallGap
    }

    Cell {
        id: suit1
        stack: 0
        maxStack: 13
        acceptedSuits:[1]
        suitChar: "\u2660"
        type: "suitcell"
        x: deviceOrientation === Orientation.Portrait ? cell4.x + cell4.width + bigGap/*270*/ :  cell4.x + cell4.width + bigGap
        y: deviceOrientation === Orientation.Portrait ? portCellsY : landCellsY
    }

    Cell {
        id: suit2
        stack: 0
        maxStack: 13
        acceptedSuits:[2]
        type: "suitcell"
        suitChar: "\u2663"
        x: deviceOrientation === Orientation.Portrait ? suit1.x + suit1.width + smallGap  : suit1.x/*334*/
        y: deviceOrientation === Orientation.Portrait ? portCellsY : suit1.y + suit1.height + smallGap
    }
    Cell {
        id: suit3
        stack: 0
        maxStack: 13
        acceptedSuits:[3]
        type: "suitcell"
        suitChar: "\u2665"
        x: deviceOrientation === Orientation.Portrait ? suit2.x + suit2.width + smallGap  : suit1.x/*398*/
        y: deviceOrientation === Orientation.Portrait ? portCellsY : suit2.y + suit2.height + smallGap
    }
    Cell {
        id: suit4
        stack: 0
        maxStack: 13
        acceptedSuits:[4]
        type: "suitcell"
        suitChar: "\u2666"
        x: deviceOrientation === Orientation.Portrait ? suit3.x + suit3.width + smallGap  : suit1.x/*462*/
        y: deviceOrientation === Orientation.Portrait ? portCellsY : suit3.y + suit3.height + smallGap
    }

    Cell {
        id: field1
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? portCellsX : landFieldsX
        y: deviceOrientation === Orientation.Portrait ? suit4.y + suit4.height + cellGap : landFieldsY/*120*/
    }

    Cell {
        id: field2
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field1.x + field1.width + smallGap/*74*/ : field1.x + field1.width + smallGap
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }
    Cell {
        id: field3
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field2.x + field2.width + smallGap/*138*/ : field2.x + field2.width + smallGap
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }
    Cell {
        id: field4
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field3.x + field3.width + smallGap/*202*/ : field3.x + field3.width + smallGap
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }

    Cell {
        id: field5
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field4.x + field4.width + smallGap : field4.x + field4.width + smallGap /*270*/
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }

    Cell {
        id: field6
        stack: 0
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field5.x + field5.width + smallGap : field5.x + field5.width + smallGap /*334*/
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }
    Cell {
        stack: 0
        id: field7
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field6.x + field6.width + smallGap : field6.x + field6.width + smallGap /*398*/
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }
    Cell {
        stack: 0
        id: field8
        type: "freecell"
        x: deviceOrientation === Orientation.Portrait ? field7.x + field7.width + smallGap : field7.x + field7.width + smallGap /*462*/
        y: deviceOrientation === Orientation.Portrait ? field1.y : landFieldsY
    }

    property var blackSuits : [1, 2]
    property var redSuits : [3, 4]
    property var deckArray : []
    property var cardsArray : []
    property var suitCells : [suit1, suit2, suit3, suit4]
    property var moves : []
    function resetField()
    {
        if (Qt.animating !== 0)
        {
            return;
        }

        moves = [];
        canAutoMove = false;
        Qt.freeCells = 12;
        Qt.animating = 0;
        var cardPlaces = [field1, field2, field3, field4, field5, field6, field7, field8];

        var placeIndex = 0;

        field1.reset()
        field2.reset()
        field3.reset()
        field4.reset()
        field5.reset()
        field6.reset()
        field7.reset()
        field8.reset()
        cell1.reset()
        cell2.reset()
        cell3.reset()
        cell4.reset()
        suit1.reset()
        suit2.reset()
        suit3.reset()
        suit4.reset()

        for (var i = 0; i < cardsArray.length; i++)
        {
            var card = cardsArray[i];
            card.reset();
//            if ('type' in card.parent)
//            {
//                card.parent.removeCard(card);
//            }
            deckArray.push(card);
        }

        while (deckArray.length > 0)
        {
            var nextIndex = Math.floor(Math.random() * deckArray.length);

            var next = deckArray.splice(nextIndex, 1).pop();

            if (next == null)
            {
                console.log("Error");
            }

            cardPlaces[placeIndex % 8].dropCard(next);
            cardPlaces.splice(placeIndex % 8, 1, next);

            placeIndex = placeIndex + 1;

        }
        canAutoMove = true;
    }

    function movemade(move)
    {
        if (!canAutoMove)
        {
            return;
        }
        console.log("moved");


        for (var i = 0; i < cardsArray.length; i++)
        {
            var card = cardsArray[i];
            if (card.stack === 0 && card.state !== "running")
            {
                var suitCell = suitCells[card.suit - 1];
                if (suitCell.stack + 1 === card.rank)
                {
                    if ((suitCells[card.acceptedSuits[0] - 1].stack >= card.rank - 1 &&
                         suitCells[card.acceptedSuits[1] - 1].stack >= card.rank - 1 ) ||
                        card.rank === 2)
                    {
                        var autoMove =  {moved : card, from : card.parent, to : suitCell};
                        move.push(autoMove);
                        card.lastMove = move;
                        card.parent.removeCard(card);

                        card.toTopLevel();

                        card.targetParent = suitCell;

                        card.state = "running";
                        Qt.animating = Qt.animating + 1;

                        break;
                    }
                }
            }
         }



    }

    function undoMove()
    {
        if (moves.length === 0 || Qt.animating !== 0)
        {
            return;
        }
        var lastMove = moves.pop();
        while (lastMove.length > 0)
        {
            var move = lastMove.pop();
            console.log(move);
            move.moved.parent.removeCard(move.moved);
            move.from.dropCard(move.moved);
        }
    }

    Item
    {

        Component.onCompleted: {

            Qt.animating = 0;
            var component = Qt.createComponent("Card.qml");
            var aSuits;
            var suitChar;
            var suitColor;
            var rankChar;
            for (var suit = 1; suit < 5; suit++)
            {
                for (var rank = 1; rank < 14; rank++)
                {


                    if (suit === 1) {
                        aSuits = redSuits;
                        suitChar = "\u2660";
                        suitColor = "black";
                    } else if (suit === 2) {
                        aSuits = redSuits;
                        suitChar = "\u2663";
                        suitColor = "black";
                    } else if (suit === 3) {
                        aSuits = blackSuits;
                        suitChar = "\u2665";
                        suitColor = "red";
                    } else if (suit === 4) {
                        aSuits = blackSuits;
                        suitChar = "\u2666";
                        suitColor = "red";
                    }

                    if (rank === 1)
                    {
                        rankChar = "A";
                    } else if (rank === 11)
                    {
                        rankChar = "J";
                    } else if (rank === 12)
                    {
                        rankChar = "Q";
                    } else if (rank === 13)
                    {
                        rankChar = "K";
                    } else
                    {
                        rankChar = rank.toString();
                    }

                    var card = component.createObject(playfield,
                                                        { "rank": rank,
                                                          "rankChar": rankChar,
                                                          "suit": suit,
                                                          "suitChar": suitChar,
                                                          "acceptedSuits" : aSuits,
                                                          "suitColor" : suitColor,
                                                          "field" : playfield
                                                      });


                    cardsArray.push(card);
                }
            }
            resetField();

        }
    }

}
