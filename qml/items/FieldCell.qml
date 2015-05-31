import QtQuick 2.0
Cell {
    id: "cell"
    type: "freecell"

    function decreaseFreeCells()
    {
        if (stack === 0)
        {
            Qt.freeCells = Qt.freeCells - 1
            Qt.freeFieldCells = Qt.freeFieldCells - 1;
        }
    }

    function increaseFreeCells()
    {
        Qt.freeCells = Qt.freeCells + 1
        Qt.freeFieldCells = Qt.freeFieldCells + 1;
    }

    function adjustCardDrop(Card)
    {
        if (Card.stack === 0)
        {
            Card.setDrop(true)
        }
    }

    function freeFieldCells()
    {
        return Qt.freeFieldCells - 1; // overwritten in FieldCell
    }
}
