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

        text: 'Go'
        iconName: 'edit-link'

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        visible: item !== null && (buttonsAlwaysVisible || !buttonsShouldHide) && (typeof item.href !== 'undefined') && (typeof item.onclick === 'undefined' || item.onclick !== 'href')

        onClicked: {
            if (item !== null && item.href !== undefined) {
                executable.exec('xdg-open '+item.href);
            }
        }
    }

    IconifiableButton {
        id: runButton
        iconMode: mousearea.iconMode

        text: 'Run'
        iconName: 'run-build'

        anchors.right: goButton.visible? goButton.left: parent.right
        anchors.rightMargin: goButton.visible? (mousearea.iconMode ? 0 : 5): 0
        anchors.verticalCenter: parent.verticalCenter

        visible: item!==null && (buttonsAlwaysVisible  || !buttonsShouldHide) && (typeof item.bash !== 'undefined') && (typeof item.onclick === 'undefined' || item.onclick !== 'bash')

        onClicked: {
            if (item !== null && item.bash !== undefined) {
                if (item.terminal !== undefined && item.terminal === 'true') {
                    executable.exec('konsole --noclose -e '+item.bash);
                } else {
                    executable.exec(item.bash);
                }
            }
        }
    }
}