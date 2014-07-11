
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
        Dragged.stack + 1 > Qt.freeCells)
    {
        return false;
    }
    else
    {
        return true;
    }
}
