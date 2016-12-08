/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../items"

Page {
    property string name: "mainPage"
    id: page
    allowedOrientations: Orientation.Portrait|Orientation.Landscape

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
//        PullDownMenu {
//            MenuItem {
//                text: "Reset"
//                onClicked: {field.resetField()}//pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
//            }
//        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Rectangle {
             y: 0
            id: column

            width: page.width

            Rectangle
            {
                id: rect
                y: deviceOrientation === Orientation.Portrait ? 12 : 0
                x: deviceOrientation === Orientation.Portrait ? 0 : 12
                width: deviceOrientation === Orientation.Portrait ? page.width : 80 * Theme.pixelRatio
                anchors.left: deviceOrientation === Orientation.Portrait ? column.left : undefined
                height: deviceOrientation === Orientation.Portrait ? 60 * Theme.pixelRatio : page.height
                color : "transparent"
                //border.color: "white"
                //border.width: 1
                Button
                {
                    id: undoMove
                    anchors.left: deviceOrientation === Orientation.Portrait ? rect.left : rect.left
                    width:  deviceOrientation === Orientation.Portrait ? rect.width / 2 : rect.width
                    height: deviceOrientation === Orientation.Portrait ? rect.height : rect.height / 2
                    text : "Undo"
                    anchors.top: deviceOrientation === Orientation.Portrait ? rect.top : undefined
                    anchors.bottom: deviceOrientation === Orientation.Portrait ? undefined : rect.bottom
                    //rotation : deviceOrientation === Orientation.Portrait ? 0 : -90
                    onClicked:
                    {
                        field.undoMove();
                    }
                }
                Button
                {
                    id: newGame
                    width:  deviceOrientation === Orientation.Portrait ? rect.width / 2 : rect.width
                    height: deviceOrientation === Orientation.Portrait ? rect.height : rect.height / 2
                    y: deviceOrientation === Orientation.Portrait ? 0 : rect.height
                    anchors.top: deviceOrientation === Orientation.Portrait ? rect.top : rect.top
                    anchors.right: deviceOrientation === Orientation.Portrait ? rect.right : rect.right

                    text : deviceOrientation === Orientation.Portrait ? "New Game" : " New\nGame"
                    //rotation : deviceOrientation === Orientation.Portrait ? 0 : -90

                    onClicked:
                    {
                        field.resetField(false);
                    }

                    onPressAndHold:
                    {
                        field.resetField(true);
                    }

                }
            }
            PlayField
            {
                id: field
                y: deviceOrientation === Orientation.Portrait ? rect.height + 20 : 0
                x: deviceOrientation === Orientation.Portrait ? 0 : (rect.height <= 540 ? 0 : newGame.width) // jolla phone special
            }
        }
    }
}


