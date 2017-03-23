import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    
    id: compactRoot
    
    Layout.preferredWidth: rotator.implicitWidth
    
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
    
    FirstLinesRotator {
        id: rotator
    }
}


