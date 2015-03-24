import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

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
    property int landFieldsX : 112
    property int portCellsX : 12
    property int portCellsY : 0
    property var selectedCard : null
    property var db

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
    property var cells: [cell1, cell2, cell3, cell4, suit1, suit2, suit3, suit4, field1, field2, field3, field4, field5, field6, field7, field8]
    property var moves : []
    property var rejectedDrop : []

    function resetField()
    {
        if (Qt.animating !== 0 || Qt.reset === 1)
        {
            return;
        }

        db.transaction(
           function(tx) {
               tx.executeSql('DELETE FROM CardPos')
               tx.executeSql('DELETE FROM Move')
           }
        )

        Qt.reset = 1;

        var d=0;
        moves = [];
        canAutoMove = false;
        Qt.freeCells = 12;
        Qt.animating = 0;
        var cardPlaces = [field1, field2, field3, field4, field5, field6, field7, field8];
        var placeIndex = 0;
        resetCells()

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

        var bulkMove = []
        while (deckArray.length > 0)
        {
            var nextIndex = Math.floor(Math.random() * deckArray.length);

            var next = deckArray.splice(nextIndex, 1).pop();

            if (next == null)
            {
                console.log("Error");
            }

            //cardPlaces[placeIndex % 8].dropCard(next);
            bulkMove.push({card : next, to:  cardPlaces[placeIndex % 8] })
            //makeMove(next, cardPlaces[placeIndex % 8], true)
            cardPlaces.splice(placeIndex % 8, 1, next);

            placeIndex = placeIndex + 1;

        }
        makeBulkMove(bulkMove)
        canAutoMove = true;

        Qt.reset = 0;
    }

    function resetCells()
    {
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
    }

    function makeBulkMove(bulkMove)
    {
        if (bulkMove.length > 0)
        {
            db.transaction(
                function(tx) {
                    for (var i = 0; i < bulkMove.length; i++) {
                        bulkMove[i].to.dropCard(bulkMove[i].card);

                        tx.executeSql('INSERT INTO CardPos VALUES(?, ?)', [bulkMove[i].card.dbId, bulkMove[i].to.dbId])

                    }
                }
            )
        }
    }

    function movemade(move)
    {
        db.transaction(
            function(tx) {
                //for (var i = 0; i < move.length; i++)
                if (move.length > 0)
                {
                    //Move(Id INT PRIMARY KEY AUTOINCEREMENT, parentId INT, cardId INT NOT NULL, fromId INT NOT NULL, toId INT NOT NULL)
                    tx.executeSql('INSERT INTO Move (parentId, cardId, fromId, toId) VALUES(?, ?, ?, ?)',
                                  [moves.length, move[move.length - 1].moved.dbId, move[move.length - 1].from.dbId, move[move.length - 1].to.dbId])
                }
            }
        )

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
                if (tryMoveToSuitCell(card, move, true))
                {
                    break;
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

        var parentId = moves.length
        db.transaction(
           function(tx) {
               tx.executeSql('DELETE FROM Move WHERE parentId = ?', [parentId])
           }
        )

        var lastMove = moves.pop();
        while (lastMove.length > 0)
        {
            var move = lastMove.pop();
            makeMove(move.moved, move.from, true)

            //makeMove(move);
            //move.moved.parent.removeCard(move.moved);
            //move.from.dropCard(move.moved);
        }
    }

    function makeMove(card, to, saveToDb)
    {
        if (card.parent.type !== "playfield")
        {
            card.parent.removeCard(card);
        }
        to.dropCard(card);

        if (saveToDb)
        {
            db.transaction(
               function(tx) {
                   tx.executeSql('DELETE FROM CardPos WHERE cardId = ?', [card.dbId])
                   tx.executeSql('INSERT INTO CardPos VALUES(?, ?)', [card.dbId, to.dbId])

               }
            )
        }
    }

    function makeAnimatedMove(parentmove, move)
    {
        move.moved.lastMove = parentmove;
        move.moved.parent.removeCard(move.moved);
        move.moved.toTopLevel();
        move.moved.targetParent = move.to;
        move.moved.state = "running";
        Qt.animating = Qt.animating + 1;

        db.transaction(
           function(tx) {
               tx.executeSql('DELETE FROM CardPos WHERE cardId = ?', [move.moved.dbId])
               tx.executeSql('INSERT INTO CardPos VALUES(?, ?)', [move.moved.dbId, move.to.dbId])

               //tx.executeSql('INSERT INTO Move (parentId, cardId, fromId, toId) VALUES(?, ?, ?, ?)', [moves.length, move.moved.dbId, move.from.dbId, move.to.dbId])
           }
        )
    }

    function tryMoveToSuitCell(card, parentmove, checkOtherSuits)
    {
        if (checkOtherSuits)
        {
            if ((suitCells[card.acceptedSuits[0] - 1].stack < card.rank - 1 ||
                 suitCells[card.acceptedSuits[1] - 1].stack < card.rank - 1) &&
                card.rank !== 2)
            {
                return false;
            }
        }

        var suitCell = suitCells[card.suit - 1];
        if (suitCell.stack + 1 === card.rank)
        {

            var autoMove =  {moved : card, from : card.parent, to : suitCell};
            parentmove.push(autoMove);
            makeAnimatedMove(parentmove, autoMove);

            return true;

        }

        return false;
    }

//    function sendOnEntered(drag, rejectCard)
//    {
//        rejectedDrop.push(rejectCard);

//        childAt(drag.x, drag.y)
//        //for (var i = 0; i < cardsArray.length; i++)
//        //{
//        //    var card = cardsArray[i];
//        //    if (card.)
//        //}
//    }

    function getWithdbId(dbId)
    {
        if (dbId < 52)
        {
            return cardsArray[dbId];
        }
        else
        {
            return cells[dbId - 52];
        }
    }

    Item
    {

        Component.onCompleted: {

            Qt.freeCells = 12;

            resetCells();
            db = LocalStorage.openDatabaseSync("SailFreeCellDB", "1.0", "Database", 1000000);
            var rs = null;
            var movesRS = null;
            var stateWasSaved = false;
            db.transaction(
                function(tx) {
                    // Drop table if update needed
                    //tx.executeSql('DROP TABLE IF EXISTS CardPos');
                    //tx.executeSql('DROP TABLE IF EXISTS Move');

                    // Create the database if it doesn't already exist
                    tx.executeSql('CREATE TABLE IF NOT EXISTS CardPos(cardId INT NOT NULL UNIQUE, posId INT NOT NULL)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Move(Id INTEGER PRIMARY KEY AUTOINCREMENT, parentId INT, cardId INT NOT NULL, fromId INT NOT NULL, toId INT NOT NULL)');


                    rs = tx.executeSql('SELECT * FROM CardPos');

                    if (rs.rows.length > 0)
                    {
                       stateWasSaved = true;
                    }

                    movesRS = tx.executeSql('SELECT Id, parentId, cardId, fromId, toId FROM Move ORDER BY parentId, Id');

                }
            )

            Qt.animating = 0;
            var component = Qt.createComponent("Card.qml");
            var aSuits;
            var suitChar;
            var suitColor;
            var rankChar;
            var dbId = 0;
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
                                                        { "dbId": dbId,
                                                          "rank": rank,
                                                          "rankChar": rankChar,
                                                          "suit": suit,
                                                          "suitChar": suitChar,
                                                          "acceptedSuits" : aSuits,
                                                          "suitColor" : suitColor,
                                                          "field" : playfield
                                                      });

                    card.reset();
                    cardsArray.push(card);
                    dbId++;
                }
            }
            cardsArray.sort(function(a, b) { return a.dbId - b.dbId })

            var cellId = 52;
            for(var j = 0; j < cells.length; j++)
            {
                cells[j].dbId = cellId;
                cellId++;
            }


            if (stateWasSaved)
            {
                for(var i = 0; i < rs.rows.length; i++) {
                    var cardId = rs.rows.item(i).cardId
                    var posId = rs.rows.item(i).posId

                    var to = getWithdbId(posId);

                    makeMove(cardsArray[cardId], to, false);
                }

                var currentId = 0;
                var currentMove = [];
                for(var row = 0; row < movesRS.rows.length; row++) {
                    var parentId = movesRS.rows.item(row).parentId
                    var movedCard = cardsArray[movesRS.rows.item(row).cardId]
                    var fromItem = getWithdbId(movesRS.rows.item(row).fromId)
                    var toItem = getWithdbId(movesRS.rows.item(row).toId)

                    if (currentId === parentId)
                    {
                        currentMove.push({moved : movedCard, from : fromItem, to : toItem})
                    }
                    else
                    {
                        if (currentMove.length > 0)
                        {
                            moves.push(currentMove.slice(0));
                        }
                        currentMove = [];
                        currentMove.push({moved : movedCard, from : fromItem, to : toItem})
                        currentId = parentId
                    }
                }
                if (currentMove.length > 0)
                {
                    moves.push(currentMove)
                }

//                for (var k = 0; k < moves.length; k++)
//                {
//                    var m = moves[k];
//                    for (var l = 0; l < m.length; l++)
//                    {
//                        console.log(k + " " + l + " " + m[l].moved.dbId + " " + m[l].from.dbId + " " + m[l].to.dbId);
//                    }
//                }
                canAutoMove = true;

            }
            else
            {
                resetField();
            }
        }


    }

}
