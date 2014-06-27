/*
 * Copyright (c) 2014 Dickson Leong.
 * All rights reserved.
 *
 * This file is part of GagBook.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root
    width: ListView.view.width
    height: mainColumn.height + 2 * mainColumn.anchors.topMargin + seperator.height

    Column {
        id: mainColumn
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: Theme.paddingLarge }
        height: childrenRect.height
        spacing: Theme.paddingMedium

        Text {
            anchors { left: parent.left; right: parent.right; margins: Theme.paddingMedium }
            font.pixelSize: Theme.fontSizeMedium
            font.bold: true
            color: Theme.primaryColor
            wrapMode: Text.Wrap
            text: model.title
        }

        Row {
            anchors { left: parent.left; right: parent.right; margins: Theme.paddingMedium  }
            spacing: Theme.paddingMedium

            CustomCountBubble {
                value: model.votesCount
                text: "points"
            }

            CustomCountBubble {
                value: model.commentsCount
                text: "comments"
            }

        }

        Image {
            id: gagImage

            function __calculateImageHeight() {
                var width = 460, height = model.imageHeight;
                if (height > QMLUtils.IMAGE_MAX_HEIGHT) {
                    width *= QMLUtils.IMAGE_MAX_HEIGHT / height;
                    height = QMLUtils.IMAGE_MAX_HEIGHT;
                }
                if (width > gagImage.width)
                   height *= gagImage.width / width;
                return height || gagImage.width;
            }

            anchors { left: parent.left; right: parent.right }
            height: __calculateImageHeight()
            sourceSize.height: QMLUtils.IMAGE_MAX_HEIGHT
            asynchronous: true
            smooth: !root.ListView.view.moving
            cache: false
            fillMode: Image.PreserveAspectFit
            source: model.imageUrl

            Loader {
                id: errorTextLoader
                anchors.fill: parent
                sourceComponent: {
                    if (model.isNSFW) return nsfwText;
                    if (!gagImage.source.toString()) {
                        if (model.isDownloading)
                            return downloadingIndicator;
                        return notDownloadedText;
                    }

                    switch (gagImage.status) {
                    case Image.Loading: return loadingRect;
                    case Image.Error: return errorText;
                    case Image.Ready:
                        if (model.isGIF) return gifPlayIcon;
                        if (model.isVideo) return videoPlayIcon;
                        // fallthrough
                    default: return undefined;
                    }
                }

                Component {
                    id: nsfwText

                    Item {
                        Column {
                            anchors {
                                left: parent.left; right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            height: childrenRect.height
                            spacing: Theme.paddingMedium

                            Text {
                                anchors { left: parent.left; right: parent.right }
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.primaryColor
                                font.bold: true
                                wrapMode: Text.Wrap
                                text: "Not Safe For Work"
                            }

                            Text {
                                anchors { left: parent.left; right: parent.right }
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.primaryColor
                                wrapMode: Text.Wrap
                                text: "Unfortunately, GagBook does not support viewing NSFW images yet"
                            }
                        }
                    }
                }

                Component {
                    id: notDownloadedText

                    Item {
                        Column {
                            anchors {
                                left: parent.left; right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            height: childrenRect.height
                            spacing: Theme.paddingMedium

                            Text {
                                anchors { left: parent.left; right: parent.right }
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.primaryColor
                                font.bold: true
                                wrapMode: Text.Wrap
                                text: "Image not downloaded"
                            }

                            Text {
                                anchors { left: parent.left; right: parent.right }
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.primaryColor
                                wrapMode: Text.Wrap
                                text: "Click to download image"
                            }
                        }
                    }
                }

                Component {
                    id: downloadingIndicator

                    Item {
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: true
                            visible: running
                            size: BusyIndicatorSize.Large
                        }
                    }
                }

                Component {
                    id: errorText

                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.primaryColor
                        wrapMode: Text.Wrap
                        text: "Error loading image"
                    }
                }

                Component {
                    id: loadingRect

                    Rectangle { color: "#000" }
                }

                Component {
                    id: gifPlayIcon

                    Item {
                        Image {
                            anchors.centerIn: parent
                            source: "Images/icon-gif-play.png"
                        }
                    }
                }

                Component {
                    id: videoPlayIcon

                    Item {
                        Image {
                            anchors.centerIn: parent
                            source: "Images/icon-video-play.png"
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (model.isNSFW) return;
                    if (model.isVideo) {
                        Qt.openUrlExternally(model.url);
                        return;
                    }
                    if (!gagImage.source.toString()) {
                        gagModel.downloadImage(index);
                        return;
                    }
                    if (model.isGIF && !model.gifImageUrl.toString())
                        gagModel.downloadImage(index);
                    pageStack.push(Qt.resolvedUrl("ImagePage.qml"), { gag: model })
                }
            }
        }

        /*ButtonRow{
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            height: childrenRect.height
            exclusive: false

            Button {
                iconSource: "image://theme/icon-m-toolbar-new-message" + (appSettings.whiteTheme ? "" : "-selected")
                onClicked: pageStack.push(Qt.resolvedUrl("CommentsPage.qml"), { gagURL: model.url })
            }
            Button {
                iconSource: "image://theme/icon-l-browser-main-view"
                onClicked: dialogManager.createOpenLinkDialog(model.url)
            }
            Button {
                iconSource: "image://theme/icon-m-toolbar-share" + (appSettings.whiteTheme ? "" : "-selected")
                onClicked: QMLUtils.shareLink(model.url, model.title);
            }
            Button {
                property string __savedFilePath: ""
                iconSource: {
                    if (!__savedFilePath)
                        return "image://theme/icon-s-transfer-download" + (appSettings.whiteTheme ? "" : "-inverse")
                    else
                        return "image://theme/icon-m-toolbar-gallery" + (appSettings.whiteTheme ? "" : "-selected")
                }
                onClicked: {
                    if (!__savedFilePath) {
                        if (model.isGIF && !model.gifImageUrl.toString()) {
                            infoBanner.alert("You have to download the GIF first by clicking on the image");
                            return;
                        }
                        __savedFilePath = QMLUtils.saveImage(model.isGIF ? model.gifImageUrl : model.imageUrl);
                        if (__savedFilePath) {
                            var displayPath = __savedFilePath;
                            if (displayPath.indexOf("file://") == 0)
                                displayPath = displayPath.substring(7);
                            infoBanner.alert("Image saved to " + displayPath);
                        } else {
                            infoBanner.alert("Unable to save image");
                        }
                    } else {
                        Qt.openUrlExternally(__savedFilePath);
                        __savedFilePath = "";
                    }
                }
            }
        }*/
    }

    Rectangle {
        id: seperator
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: "white"
    }
}
