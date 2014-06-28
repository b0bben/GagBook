CONFIG += sailfishapp

TARGET = gagbook

VERSION = 0.9.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += network xml xmlpatterns

# Qt-Json
HEADERS += qt-json/json.h \
    src/ninegagrequest.h
SOURCES += qt-json/json.cpp \
    src/ninegagrequest.cpp

HEADERS += \
    src/qmlutils.h \
    src/appsettings.h \
    src/gagbookmanager.h \
    src/gagmodel.h \
    src/gagobject.h \
    src/gagrequest.h \
    src/infinigagrequest.h \
    src/networkmanager.h \
    src/gagimagedownloader.h \
    src/gagcookiejar.h

SOURCES += main.cpp \
    src/qmlutils.cpp \
    src/appsettings.cpp \
    src/gagbookmanager.cpp \
    src/gagmodel.cpp \
    src/gagobject.cpp \
    src/gagrequest.cpp \
    src/infinigagrequest.cpp \
    src/networkmanager.cpp \
    src/gagimagedownloader.cpp \
    src/gagcookiejar.cpp


OTHER_FILES += \
    README.md \
    LICENSE \
    qml/* \
    qml/Images/* \
    gagbook.desktop \
    rpm/gagbook.yaml \
    gagbook.png

