/*
 * Copyright (c) 2012-2013 Dickson Leong.
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

import QtQuick 1.1
import com.nokia.symbian 1.1
import GagBook 1.0

Page {
    id: mainPage

    tools: ToolBarLayout {
        ToolButton {
            platformInverted: settings.whiteTheme
            iconSource: "Images/close_stop" + (platformInverted ? "_inverted.svg" : ".svg")
            onClicked: Qt.quit()
        }
        ToolButton {
            platformInverted: settings.whiteTheme
            iconSource: "toolbar-list"
            onClicked: dialogManager.createSectionDialog()
        }
        ToolButton {
            platformInverted: settings.whiteTheme
            iconSource: gagManager.busy ? ("Images/close_stop" + (platformInverted ? "_inverted.svg" : ".svg"))
                                        : "toolbar-refresh"
            onClicked: {
                if (gagManager.busy)
                    gagManager.stopRefresh()
                else
                    gagManager.refresh(GagManager.RefreshAll)
            }
        }
        ToolButton {
            platformInverted: settings.whiteTheme
            iconSource: "toolbar-menu"
            onClicked: mainMenu.open()
        }
    }

    Menu {
        id: mainMenu
        platformInverted: settings.whiteTheme

        MenuLayout {
            MenuItem {
                platformInverted: settings.whiteTheme
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                platformInverted: settings.whiteTheme
                text: "About GagBook"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }

    ListView {
        id: gagListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: gagManager.model
        orientation: ListView.Vertical
        delegate: GagDelegate {}
        footer: Item {
            width: ListView.view.width
            height: ListView.view.count > 0 ? footerColumn.height + 2 * constant.paddingLarge
                                            : ListView.view.height
            visible: gagManager.busy

            Column {
                id: footerColumn
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: childrenRect.height
                spacing: constant.paddingMedium

                Text {
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: "Downloading..."
                }

                ProgressBar {
                    anchors.horizontalCenter: parent.horizontalCenter
                    platformInverted: settings.whiteTheme
                    width: parent.width * 0.75
                    value: gagManager.progress
                    // when indeterminate change from true to false the indeterminate
                    // graphic is still there (bug?)
                    //indeterminate: gagManager.progress == 0
                }
            }
        }

        onAtYEndChanged: if (atYEnd && !gagManager.busy && count > 0) gagManager.refresh(GagManager.RefreshOlder)
    }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: sectionModel.get(settings.selectedSection).text
        busy: gagManager.busy
        onClicked: gagListView.positionViewAtBeginning()
    }

    QtObject {
        id: dialogManager

        property Component __sectionDialogComponent: null
        property Component __openLinkDialogComponent: null
        property Component __shareDialogComponent: null

        function createSectionDialog() {
            if (!__sectionDialogComponent) __sectionDialogComponent = Qt.createComponent("SectionDialog.qml")
            var dialog = __sectionDialogComponent.createObject(mainPage)
            if (!dialog) {
                console.log("Error creating object: " + __sectionDialogComponent.errorString())
                return
            }
            dialog.accepted.connect(function() {
                settings.selectedSection = dialog.selectedIndex;
                gagManager.refresh(GagManager.RefreshAll)
            })
        }

        function createOpenLinkDialog(link) {
            if (!__openLinkDialogComponent) __openLinkDialogComponent = Qt.createComponent("OpenLinkDialog.qml")
            var dialog = __openLinkDialogComponent.createObject(mainPage, { link: link })
            if (!dialog) console.log("Error creating object: " + __openLinkDialogComponent.errorString())
        }

        function createShareDialog(link) {
            if (!__shareDialogComponent) __shareDialogComponent = Qt.createComponent("ShareDialog.qml")
            var dialog = __shareDialogComponent.createObject(mainPage, { link: link })
            if (!dialog) console.log("Error creating object: " + __shareDialogComponent.errorString())
        }
    }
}
