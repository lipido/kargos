import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore


PlasmaComponents.Label {
    
    id: compactRoot
    
    text: (rotatingItems.length > 0) ? rotatingItems[currentMessage].title : 'starting...'
    
    Layout.preferredWidth: compactRoot.implicitWidth
    
    Component.onCompleted: { 
        rotationTimer.running = true
    }

    property var rotatingItems : []
    
    property int currentMessage : -1
    
    MouseArea {
        anchors.fill : parent
        onClicked: {            
            if (root.currentItemsInCommand > 0 && !plasmoid.expanded) {
                plasmoid.expanded = true;            
            } else if (plasmoid.expanded) {
                plasmoid.expanded = false;
            }
        }
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
            compactRoot.currentMessage = -1;
        } else if (compactRoot.currentMessage >= newItems.length) {
            compactRoot.currentMessage = 0;
        } else if (compactRoot.currentMessage === -1) {
            compactRoot.currentMessage = 0;
        }
        
        compactRoot.rotatingItems = newItems;
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
            if (rotatingItems.length > 0) {
                compactRoot.currentMessage = (compactRoot.currentMessage + 1) % compactRoot.rotatingItems.length;
            }
        }
    }
}


