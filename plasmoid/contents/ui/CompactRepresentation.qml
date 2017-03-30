import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    
    id: compactRoot
    
    Layout.preferredWidth: rotator.implicitWidth + (dropdownButton.visible?dropdownButton.implicitWidth + 5 : 0)

    property var mouseIsInside: false;
    
    MouseArea {
        id: mousearea
        hoverEnabled: true
        anchors.fill : parent

        onEntered: {
            dropdownButton.checked = plasmoid.expanded; //this seems redundant, but fixes some lost updates
            mouseIsInside = true;
            mouseExitDelayer.stop();
        }

        onExited: {
            dropdownButton.checked = plasmoid.expanded; //this seems redundant, but fixes some lost updates
            mouseExitDelayer.restart();
        }
        
        onClicked: {
            if (!rotator.mousearea.hasClickAction && root.dropdownItemsCount > 0) {
                doDropdown();
            }
        }

        Timer {
            id: mouseExitDelayer
            interval: 1000
            onTriggered: {
                mouseIsInside = false;
            }
        }

        function doDropdown() {
            if (!plasmoid.expanded) {
                plasmoid.expanded = true;
                dropdownButton.checked = true; //this seems redundant, but fixes some lost updates
                mouseExitDelayer.stop();
            } else if (plasmoid.expanded) {
                plasmoid.expanded = false;
                dropdownButton.checked = false; //this seems redundant, but fixes some lost updates
            }
        }

        FirstLinesRotator {
            id: rotator
            buttonHidingDelay: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Button {
            id: dropdownButton
            checkable: true
            checked: plasmoid.expanded
            iconName: {
                if (plasmoid.location == PlasmaCore.Types.BottomEdge) {
                    return plasmoid.expanded? "arrow-down": "arrow-up";
                } else if (plasmoid.location == PlasmaCore.Types.TopEdge) {
                    return plasmoid.expanded? "arrow-up": "arrow-down";
                } else if (plasmoid.location == PlasmaCore.Types.LeftEdge) {
                    return plasmoid.expanded? "arrow-left": "arrow-right";
                } else {
                    return plasmoid.expanded? "arrow-right": "arrow-left";
                }
            }

            anchors.verticalCenter: parent.verticalCenter
            visible: root.dropdownItemsCount > 0 && (mouseIsInside || plasmoid.expanded || plasmoid.configuration.dropdownvisible)
            width: visible? dropdownButton.implicitWidth:0
            anchors.right: parent.right

            onClicked: {
                mousearea.doDropdown()
            }
        }

        Component.onCompleted: {
            // more compact
            rotator.mousearea.goButton.text='';
            rotator.mousearea.runButton.text='';
            rotator.mousearea.buttonsAlwaysVisible = true
        }
    }
}


