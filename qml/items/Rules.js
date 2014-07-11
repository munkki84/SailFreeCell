
function canDropOnCell(Card, Cell) {
    if (Cell.type === "freecell")
    {

        if (Cell.acceptedSuits.indexOf(Card.suit) === -1 || Cell.stack !== 0 ||
            Card.stack + 1 > Qt.freeCells)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    else if (Cell.type === "suitcell")
    {
        if (Cell.acceptedSuits.indexOf(Card.suit) === -1 || Cell.stack + 1 !== Card.rank ||
            Card.stack !== 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    else if (Cell.type === "cell")
    {
        if (Cell.acceptedSuits.indexOf(Card.suit) === -1 || Cell.stack !== 0 ||
            Card.stack !== 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    return false;
}

function canDropOnCard(Dragged, Card) {
    if (Dragged.rank !== Card.rank - 1 || (Card.acceptedSuits.indexOf(Dragged.suit) === -1) ||
        Dragged.stack  > Qt.freeCells)
    {
        return false;
    }
    else
    {
        return true;
    }
}

function canDragCard(card)
{
    if (card.parent.type === "suitcell")
    {
       // console.log("is suitcell")
        return false;
    }
    else if (card.stack !== 0)
    {
        if (card.childCard.rank + 1 !== card.rank)
        {
//            console.log("child card is not smaller")
//            console.log("ccard: " + card.childCard.rank + "card: " + card.rank)
            return false;
        }
        else if (card.acceptedSuits.indexOf(card.childCard.suit) === -1)
        {
           // console.log("child card is wrong suit")
            return false;
        }
        else if (!canDragCard(card.childCard))
        {
           // console.log("child cannot be dragged")
            return false;
        }
    }
    return true;
}
