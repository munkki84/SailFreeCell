import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: "item"
    property int stack;
    property int maxStack;

    function canReleaseCard()
    {
        return true;
    }

    function acceptsSuit(suit)
    {
        return item.acceptedSuits.indexOf(suit) !== -1
    }

    function acceptsRank(rank) {
        return true;
    }

    function freeFieldCells()
    {
        return Qt.freeFieldCells; // overwritten in FieldCell
    }

    function maxMoveStack(target)
    {
        var freeFieldCells = target.freeFieldCells();
        return (Qt.freeSingleCells + 1) * (freeFieldCells * (freeFieldCells + 1) / 2 + 1) - 1;
    }

    function canReceiveCard(Dragged) {
        return item.acceptsRank(Dragged.rank)
                && item.acceptsSuit(Dragged.suit)
                && Dragged.stack <= item.maxMoveStack(item)
                && item.stack < item.maxStack;
    }

}
