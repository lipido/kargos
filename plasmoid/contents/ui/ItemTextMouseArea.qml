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
    cursorShape: (item !==null && item.refresh == 'true') ? Qt.PointingHandCursor: Qt.ArrowCursor
    
    property var item: null;
    property bool buttonHidingDelay: false
    
    onClicked: {
        if (item !== null && item.refresh == 'true') {
            root.update();
        }
        mouse.accepted = false
    }
            
    onEntered: {
        if (item !== null && item.href !== undefined) {
            goButton.visible = true;
            
            // avoid buttons to disappear on each update
            timer.running = false; 
        }
        if (item !== null && item.bash !== undefined) {
            runButton.visible = true;
            
            // avoid buttons to disappear on each update
            timer.running = false; 
        }
        
        
    }
    
    onExited: {
        if (buttonHidingDelay) buttonHidder.restart();
        else hideButtons()
        timer.running = true;
    }
    
    function reset() {
        hideButtons();
    }

    function hideButtons() {
       goButton.visible = false;
       runButton.visible = false;
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
            hideButtons()
        }
    }
    
    Button {
        id: goButton
        text: 'Go'
        anchors.right: parent.right
        visible: false
        onClicked: {
            if (item !== null && item.href !== undefined) {
                executable.exec('xdg-open '+item.href);
            }
        }
        
    }
    
    Button {
        id: runButton
        text: 'Run'
        anchors.right: goButton.visible? goButton.left: parent.right
        anchors.rightMargin: goButton.visible? 5: 0
        visible: false
        onClicked: {
            if (item !== null && item.bash !== undefined) {
                executable.exec(item.bash);
            }
        }
    }
}