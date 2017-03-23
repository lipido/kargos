import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaComponents.Label {
    
    id: control
    
    text: 'starting...'
    
    Component.onCompleted: { 
        rotationTimer.running = true
        
    }

    property var rotatingItems : []
    
    property var currentMessage : -1
    
    
    function updateText() {
        var item = getCurrentItem();
        if (item !== null) {
            text = item.title;
        } else {
            text = 'starting...';
        }
    }
    
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
            control.currentMessage = -1;
        } else if (control.currentMessage >= newItems.length) {
            control.currentMessage = 0;
        } else if (control.currentMessage === -1) {
            control.currentMessage = 0;
        }
        
        control.rotatingItems = newItems;
        
        
        if (plasmoid.configuration.command == '') {
            control.text = 'No command configured. Go to settings...';
        } else {
            updateText();
        }
    }
    
    Connections {
        target: executable
        onExited: {
                if (sourceName === plasmoid.configuration.command) {
                    update(stdout);
                }
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
            updateText();
        }
    }
    
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        
        onEntered: {
            var item = getCurrentItem();
            if (item.href !== undefined) {
                goButton.visible = true;
            }
        }
        onExited: {
            goButton.visible = false;
        }
        
        Button {
            id: goButton
            text: 'Go'
            anchors.right: parent.right
            visible: false
            onClicked: {
                var item = getCurrentItem();
                if (item.href !== undefined) {
                    executable.exec('xdg-open '+item.href);
                }
            }
        }
    }
}