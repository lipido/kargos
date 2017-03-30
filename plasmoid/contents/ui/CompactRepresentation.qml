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
            mouseIsInside = true;
            mouseExitDelayer.stop();
        }

        onExited: {
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
                mouseExitDelayer.stop();
            } else if (plasmoid.expanded) {
                plasmoid.expanded = false;
            }
        }

        FirstLinesRotator {
            id: rotator
            buttonHidingDelay: true
            anchors.verticalCenter: parent.verticalCenter
        }

        // Tooltip for arrow (taken from the systemtray plasmoid)
        Item {
            id: dropdownButton

            width: units.iconSizes.smallMedium
            height: units.iconSizes.smallMedium

            implicitWidth: units.iconSizes.smallMedium
            implicitHeight: units.iconSizes.smallMedium

            visible: root.dropdownItemsCount > 0 && (mouseIsInside || plasmoid.expanded || plasmoid.configuration.dropdownvisible)

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: arrowMouseArea
                anchors.fill: parent
                onClicked: {
                    mousearea.doDropdown()
                }

                readonly property int arrowAnimationDuration: units.shortDuration * 3

                PlasmaCore.Svg {
                    id: arrowSvg
                    imagePath: "widgets/arrows"
                }

                PlasmaCore.SvgItem {
                    id: arrow

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width

                    rotation: plasmoid.expanded ? 180 : 0
                    Behavior on rotation {
                        RotationAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }
                    }
                    opacity: plasmoid.expanded ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }
                    }

                    svg: arrowSvg
                    elementId: {
                        if (plasmoid.location == PlasmaCore.Types.BottomEdge) {
                            return "up-arrow"
                        } else if (plasmoid.location == PlasmaCore.Types.TopEdge) {
                            return "down-arrow"
                        } else if (plasmoid.location == PlasmaCore.Types.LeftEdge) {
                            return "right-arrow"
                        } else {
                            return "left-arrow"
                        }
                    }
                }

                PlasmaCore.SvgItem {
                    anchors.centerIn: parent
                    width: arrow.width
                    height: arrow.height

                    rotation: plasmoid.expanded ? 0 : -180
                    Behavior on rotation {
                        RotationAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }
                    }
                    opacity: plasmoid.expanded ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }
                    }

                    svg: arrowSvg
                    elementId: {
                        if (plasmoid.location == PlasmaCore.Types.BottomEdge) {
                            return "down-arrow"
                        } else if (plasmoid.location == PlasmaCore.Types.TopEdge) {
                            return "up-arrow"
                        } else if (plasmoid.location == PlasmaCore.Types.LeftEdge) {
                            return "left-arrow"
                        } else {
                            return "right-arrow"
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            // more compact
            rotator.mousearea.goButton.text='';
            rotator.mousearea.runButton.text='';
            rotator.mousearea.buttonsAlwaysVisible = true
            rotator.mousearea.iconMode = true
        }
    }
}


