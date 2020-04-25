/*
 * 
 * kargos
 * 
 * Copyright (C) 2017 - 2020 Daniel Glez-Peña
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this program.  If not, see
 * <http://www.gnu.org/licenses/gpl-3.0.html>.
 */
import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Row {
    id: control
    spacing: 2
    anchors.left: parent.left
    anchors.right: parent.right
    
    height: label.implicitHeight + 20
    property bool buttonHidingDelay: false
    
    property var rotatingItems : []
    property var currentMessage : -1
    property int labelMaxWidth: 0
    
    readonly property alias icon: icon
    readonly property alias image: image
    readonly property alias label: label
    readonly property alias mousearea: mousearea

    function getCurrentItem() {
        return (rotatingItems.length > 0 && currentMessage != -1) ? rotatingItems[currentMessage] : null;
    }
    
    function updateItems(){
        image.update();
        label.update();
        icon.update();
        mousearea.reset();
    }

    function update(stdout) {
        
        var beforeSeparator = true;
        var newItems = [];
        
        stdout.split('\n').forEach(function(line) {
            if (line.trim().length === 0) {
                return;
            }
            if (line.trim() === '---') {
                beforeSeparator = false;
                return;
            }
            var parsedItem = root.parseLine(line);
            if (beforeSeparator) {
                newItems.push(parsedItem);
            } else if (parsedItem.dropdown !== undefined && parsedItem.dropdown === 'false') {
                newItems.push(parsedItem);
            }
        });
        
        if (newItems.length == 0) {
            currentMessage = -1;
        } else if (currentMessage >= newItems.length) {
            currentMessage = 0;
        } else if (currentMessage === -1) {
            currentMessage = 0;
        }
        
        rotatingItems = newItems;
        
        
        if (root.command == '') {
            label.text = 'No command configured. Go to settings...';
        } else {
            updateItems();
        }
        
    }
    PlasmaCore.IconItem {
        id: icon
        visible: false
        source: 'dialog-ok'
        anchors.verticalCenter : control.verticalCenter
        height: control.height * 0.75

        function update() {
            var item = getCurrentItem();
            if (item !== null) {
                source = (item.iconName !== undefined)? item.iconName: null
            }
            if (source === null) {
                visible = false;
            } else {
                visible = true;
            }
            iconMouseArea.cursorShape = root.isClickable(item) ? Qt.PointingHandCursor: Qt.ArrowCursor;
        }

        MouseArea {
            id: iconMouseArea
            anchors.fill: parent

            onClicked: {
                var item = getCurrentItem();
                root.doItemClick(item);
            }
        }
    }
    
    Image {
        id: image
        fillMode: Image.PreserveAspectFit

        anchors.verticalCenter : control.verticalCenter
        height: control.height * 0.6

        function update() {
            var item = getCurrentItem();
            if (item !== null) {
                if (item.image !== undefined) {
                    createImageFile(item.image, function(filename) {
                        image.source = filename;
                    });
                }

                if (item.imageURL !== undefined) {
                    image.source = item.imageURL;
                }

                if (item.imageWidth !== undefined) {
                    image.sourceSize.width = item.imageWidth
                }

                if (item.imageHeight !== undefined) {
                    image.sourceSize.height = item.imageHeight
                }

                // clear image
                if (item.imageURL === undefined && item.image === undefined) {
                    image.source = '';
                }

                imageMouseArea.cursorShape = root.isClickable(item) ? Qt.PointingHandCursor: Qt.ArrowCursor;
            }
        }

        Component.onCompleted: {
            sourceSize.height = control.height
        }

        MouseArea {
            id: imageMouseArea
            anchors.fill: parent

            onClicked: {
                var item = getCurrentItem();
                root.doItemClick(item);
            }
        }
    }

    Item {
        id: labelAndButtons

        implicitWidth: label.width + (mousearea.goButton.visible? mousearea.goButton.implicitWidth + 5 :0) + (mousearea.runButton.visible?mousearea.runButton.implicitWidth + 5 : 0)
        implicitHeight: label.implicitHeight

        anchors.verticalCenter: parent.verticalCenter
        readonly property bool labelTooSmall: label.implicitWidth < mousearea.runButton.implicitWidth + mousearea.goButton.implicitWidth + 10

        PlasmaComponents.Label {
            id: label
            text: 'starting...'


            property var defaultFontFamily;
            property var defaultFontSize;
            property var defaultColor;

            anchors.verticalCenter: parent.verticalCenter

            elide: (labelMaxWidth > 0)? Text.ElideRight: Text.ElideNonde
            width: (labelMaxWidth > 0)? labelMaxWidth: label.implicitWidth

            Component.onCompleted: {
                defaultFontFamily = font.family;
                defaultFontSize = font.pointSize;
                defaultColor = color + ''; //append '' to avoid binding to color property, we want just to intialize it.
                update();
                rotationTimer.running = true
            }

            function update() {
                var item = getCurrentItem();
                if (item !== null) {
                    text = item.title;
                    if (item.font !== undefined) {
                        font.family = item.font;
                    } else {
                        font.family = defaultFontFamily;
                    }
                    if (item.size !== undefined) {
                        font.pointSize = item.size;
                    } else {
                        font.pointSize = defaultFontSize;
                    }
                    if (item.color !== undefined) {
                        color = item.color;
                    } else {
                        color = label.defaultColor
					}
                } else {
                    text = 'starting...';
                }
                mousearea.item = item;

                var _correctedMaxWidth = label.implicitWidth
            }
        }

        ItemTextMouseArea {
            id: mousearea
            buttonHidingDelay: control.buttonHidingDelay
            
            onEntered: {
                rotationTimer.running = false;
            }
            
            onExited: {
                rotationTimer.running = true;
            }

            onWheel: {
                if (wheel.angleDelta.y < 0) {
                    rotateNext();
                } else if (wheel.angleDelta.y > 0) {
                    rotatePrev();
                }
            }
        }
    }

    Connections {
        target: commandResultsDS
        onExited: {
                control.update(stdout);
        }
    }
    
    function rotateNext() {
        if (control.rotatingItems.length > 0) {
            control.currentMessage = (control.currentMessage + 1) % control.rotatingItems.length;
            updateItems();
        }
    }

    function rotatePrev() {
        if (control.rotatingItems.length > 0) {
            control.currentMessage = control.currentMessage - 1;
            if (control.currentMessage == -1) {
                control.currentMessage = control.rotatingItems.length - 1;
            }
            updateItems();
        }
    }

    Timer {
        id: rotationTimer
        interval: plasmoid.configuration.rotation * 1000
        running: false
        repeat: true
        onTriggered: {
            rotateNext();
        }
    }
}
