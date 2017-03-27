import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Row {
    id: control
    
    anchors.left: parent.left
    anchors.right: parent.right
    
    height: label.implicitHeight + 20
    property bool buttonHidingDelay: false
    
    Layout.preferredWidth: label.implicitWidth
    
    property var rotatingItems : []
    property var currentMessage : -1
    
    function getCurrentItem() {
        return (rotatingItems.length > 0 && currentMessage != -1) ? rotatingItems[currentMessage] : null;
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
        
        
        if (plasmoid.configuration.command == '') {
            label.text = 'No command configured. Go to settings...';
        } else {
            label.update();
            icon.update();
        }
        
    }
    
    PlasmaCore.IconItem {
        id: icon
        visible: false
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        function update() {
            var item = getCurrentItem();
            source = (item.iconName !== undefined)? item.iconName: null
            if (source == null) {
                visible = false;
            } else {
                visible = true;
            }
        }
    }
    
    PlasmaComponents.Label {
        id: label
        text: 'starting...'
        
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        property var defaultFontFamily;
        property var defaultFontSize;
        Component.onCompleted: {
            defaultFontFamily = font.family;
            defaultFontSize = font.pointSize;
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
            } else {
                text = 'starting...';
            }
            mousearea.item = item;
        }
        
        ItemTextMouseArea {
            id: mousearea
            buttonHidingDelay: control.buttonHidingDelay
        }
    }

    Connections {
        target: commandResultsDS
        onExited: {
                control.update(stdout);
        }
    }
    
    Timer {
        id: rotationTimer
        interval: plasmoid.configuration.rotation * 1000
        running: false
        repeat: true
        onTriggered: {
            if (control.rotatingItems.length > 0) {
                control.currentMessage = (control.currentMessage + 1) % control.rotatingItems.length;
                
            }
            label.update();
            mousearea.reset();
        }
    }
}