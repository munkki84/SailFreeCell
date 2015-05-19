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

    function maxMoveStack()
    {
        return 0; // overwritten by Card, FieldCell
    }

    function canReceiveCard(Dragged) {
        return item.acceptsRank(Dragged.rank)
                && item.acceptsSuit(Dragged.suit)
                && Dragged.stack <= item.maxMoveStack()
                && item.stack < item.maxStack;
    }

}
