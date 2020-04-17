import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ConfigPage {
    id: page

    property alias cfg_width: width.value
    property alias cfg_compactLabelMaxWidth: compactLabelMaxWidth.value
    property alias cfg_height: height.value
    property alias cfg_d_ArrowNeverVisible: d_ArrowNeverVisible.checked
    property alias cfg_d_ArrowAlwaysVisible: d_ArrowAlwaysVisible.checked
    property alias cfg_d_ArrowVisibleAsNeeded: d_ArrowVisibleAsNeeded.checked


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
        label: i18n("Compact (on panel) fixed text width (0: unlimited)")

        SpinBox {
            id: compactLabelMaxWidth
            Layout.fillWidth: true
            maximumValue: 10000
        }
    }

    ConfigSection {

        GroupBox {
            title: i18n('Dropdown arrow visible option: ')
            anchors.left: parent.left
            Layout.columnSpan: 2

            ColumnLayout {
                ExclusiveGroup { id: dropdownArrowVisibleGroup }
                RadioButton {
                    id: d_ArrowAlwaysVisible
                    text: i18n('Always visible')
                    exclusiveGroup: dropdownArrowVisibleGroup
                }
                RadioButton {
                    id: d_ArrowVisibleAsNeeded
                    text: i18n('Visible as needed')
                    exclusiveGroup: dropdownArrowVisibleGroup
                }
                RadioButton {
                    id: d_ArrowNeverVisible
                    text: i18n('Never visible')
                    exclusiveGroup: dropdownArrowVisibleGroup
                }
            }
        }

    }
}
