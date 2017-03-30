import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
        id: control
        property string text: ''
        property string iconName: ''
        
        
        width: iconMode ? controlInnerIcon.implicitWidth: controlInnerButton.implicitWidth
        height: iconMode ? controlInnerIcon.implicitHeight: controlInnerButton.implicitHeight
        
        property bool iconMode: true
        
        signal clicked()
        
        implicitWidth: iconMode ? controlInnerIcon.implicitWidth: controlInnerButton.implicitWidth
        implicitHeight: iconMode ? controlInnerIcon.implicitHeight: controlInnerButton.implicitHeight
        
        
        Button {
            id: controlInnerButton
            visible: !control.iconMode
            text: control.text
            iconName: control.iconName
            anchors.fill: parent
            
            onClicked: control.clicked()
        }
        
        PlasmaCore.IconItem {
            id: controlInnerIcon
            visible: control.iconMode
            source: control.iconName
            //anchors.fill: parent
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            
            width: controlInnerIcon.implicitWidth * 0.95
            
            // opacity: 0.5
            MouseArea {
                
                /*hoverEnabled: true
                
                onEntered: {
                    controlInnerIcon.opacity = 1.0
                }
                
                onExited: {
                    controlInnerIcon.opacity = 0.5
                }*/
                
                anchors.fill: parent
                
                onClicked: control.clicked()
            }
  
        }
    }