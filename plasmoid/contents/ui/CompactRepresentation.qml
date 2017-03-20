import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore


PlasmaComponents.Label {
    
    id: compactRoot
    text: "starting..."
    
    Layout.preferredWidth: compactRoot.implicitWidth
    
    Component.onCompleted: { 
        // first update
        root.update();
        
    }

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
       
        compactRoot.text = root.parseLine(stdout.split('\n')[0]).title;
    }
    
    Connections {
        target: executable
        onExited: {
                if (sourceName === plasmoid.configuration.command) {
                    update(stdout);
                }
        }
    }
}


