# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-sailfreecell

CONFIG += sailfishapp

SOURCES += src/SailFreeCell.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    SailFreeCell.desktop \
    qml/items/Card.qml \
    qml/items/Cell.qml \
    qml/items/PlayField.qml \
    qml/items/Rules.js \
    rpm/harbour-sailfreecell.spec \
    rpm/harbour-sailfreecell.yaml \
    qml/harbour-sailfreecell.qml

