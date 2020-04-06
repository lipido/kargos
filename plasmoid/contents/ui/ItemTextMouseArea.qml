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


MouseArea {

    id: mousearea
    anchors.fill: parent
    propagateComposedEvents: true
    hoverEnabled: true

    cursorShape: hasClickAction ? Qt.PointingHandCursor: Qt.ArrowCursor

    property bool hasClickAction: isClickable(item)

    property var item: null;
    property bool buttonHidingDelay: false

    property bool buttonsAlwaysVisible: false
    property bool buttonsShouldHide: true

    readonly property alias goButton: goButton
    readonly property alias runButton: runButton

    property bool iconMode: false

    onClicked: {
        root.doItemClick(item);

        mouse.accepted = false
    }
            
    onEntered: {
        if (buttonHidingDelay) buttonHidder.stop();
        buttonsShouldHide = false;

        if (goButton.visible || runButton.visible) {
            // avoid buttons to disappear on each update
            timer.running = false; 
        }
    }
    
    onExited: {
        if (!buttonsAlwaysVisible) {
            if (buttonHidingDelay) buttonHidder.restart();
            else hideButtons();
        }

        timer.running = true;
    }
    
    function reset() {
        if (!buttonsAlwaysVisible) {
            buttonsShouldHide = true
        }
    }

    function hideButtons() {
       buttonsShouldHide = true
    }
    

    // workaround. When the compact representation is used (kargos in a panel)
    // the buttons disappear just before being clicked. This is caused by the
    // onExited event, which hiddes all butons, is being launched before the 
    // click event on button (so, by hidding buttons, the click eventually does not
    // happen). So, we delay the button hidding in order to
    // capture the click event
    Timer {
        id: buttonHidder
        interval: 1000        
        onTriggered: {
            buttonsShouldHide = true
        }
    }

    IconifiableButton {
        id: goButton
        iconMode: mousearea.iconMode

        text: visible? 'Go to: '+item.href : ''
        iconName: 'edit-link'

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        visible: item !== null && (buttonsAlwaysVisible || !buttonsShouldHide) && (typeof item.href !== 'undefined') && (typeof item.onclick === 'undefined' || item.onclick !== 'href')

        onClicked: {
            
            if (item !== null && item.href !== undefined) {
                executable.exec('xdg-open '+item.href);
            }
            doRefreshIfNeeded(item);

        }
        
    }

    IconifiableButton {
        id: runButton
        iconMode: mousearea.iconMode

        text: visible? 'Run: '+item.bash : ''
        iconName: 'run-build'

        anchors.right: goButton.visible? goButton.left: parent.right
        anchors.rightMargin: goButton.visible? (mousearea.iconMode ? 0 : 2): 0
        anchors.verticalCenter: parent.verticalCenter

        visible: item!==null && (buttonsAlwaysVisible  || !buttonsShouldHide) && (typeof item.bash !== 'undefined') && (typeof item.onclick === 'undefined' || item.onclick !== 'bash')

        onClicked: {
            if (item !== null && item.bash !== undefined) {
                if (item.terminal !== undefined && item.terminal === 'true') {
                    executable.exec('konsole --noclose -e '+item.bash, function() {
                      root.doRefreshIfNeeded(item);
                      
                    });
                } else {
                    executable.exec(item.bash, function() {
                      root.doRefreshIfNeeded(item);          
                    });
                }
            }
            
        }
    }
}