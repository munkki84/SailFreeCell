import QtQuick 2.0

Cell {
    id: "cell"
    type: "cell"
    function decreaseFreeCells()
    {
        if (stack === 0)
        {
            Qt.freeCells = Qt.freeCells - 1;
            Qt.freeSingleCells = Qt.freeSingleCells -1;
        }
    }

    function maxMoveStack(target)
    {
        return 0;
    }

    function increaseFreeCells()
    {
        Qt.freeCells = Qt.freeCells + 1;
        Qt.freeSingleCells = Qt.freeSingleCells + 1;
    }

}
