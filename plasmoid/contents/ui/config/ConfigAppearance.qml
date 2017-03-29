import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ConfigPage {
    id: page
    
    property alias cfg_width: width.value
    property alias cfg_height: height.value
    property alias cfg_dropdownvisible: dropdownvisible.checked
    
    
    ConfigSection {
        label: i18n("Preferred width in px")
        
        SpinBox {
            id: width
            Layout.fillWidth: true        
            maximumValue: 10000
        }
    }
    
    ConfigSection {
        label: i18n("Preferred height in px")
        
        SpinBox {
            id: height
            Layout.fillWidth: true        
            maximumValue: 10000
        }
    }

    ConfigSection {
        
        CheckBox {
            id: dropdownvisible
            Layout.fillWidth: true
            text: 'Dropdown always visible'
        }
    }
}
