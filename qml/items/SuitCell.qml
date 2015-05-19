import QtQuick 2.0

Cell {
    id: "cell"
    type: "suitcell"
    maxStack: 13

    function acceptsRank(rank) {
        return cell.stack + 1 === rank;
    }

    function canReleaseCard()
    {
        return false;
    }
}
