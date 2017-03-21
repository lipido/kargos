import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

Item {
    id: fullRoot
    
    Layout.preferredWidth: 1//this value will be changed
    
    ListModel {
        id: kargosModel
    }
    
    Component.onCompleted: { 
        //first update
        root.update();     
    }
    

    // Info for submenus.
    // This structure has information of all submenus and their visibility status.
    // Since on each update the listview is regenerated, we use this structure to preserve the open/closed
    // status of submenus
    property var categories: ({});
    
    ListView {        
        id: listView
        anchors.fill: parent
        model: kargosModel
        add:{
            updateWidth()
        }
        
        delegate: Row {
            id: row
            height: (typeof category === 'undefined' || (fullRoot.categories[category] && fullRoot.categories[category].visible)) ? row.visibleHeight: 0
            visible: (typeof category === 'undefined') ? true : (fullRoot.categories[category] !== undefined && fullRoot.categories[category].visible)
            property int visibleHeight: itemLabel.height + 10
            
            PlasmaCore.IconItem {
                source: (typeof iconName !== 'undefined')? iconName: null
            }   
            
            Component.onCompleted: {
                    if (typeof category !== 'undefined') {
                        fullRoot.categories[category].rows.push(row);
                    }
            }
            
            PlasmaComponents.Label {
                id: itemLabel
                text: title.replace(/\\n/g, "<br>")
                
                MouseArea {
                    cursorShape: (typeof bash!=='undefined'|| typeof href !== 'undefined' || typeof refresh !== 'undefined') ? Qt.PointingHandCursor: Qt.ArrowCursor
                    anchors.fill: parent
                
                    onClicked: {
                        if (typeof bash !== 'undefined') {                         
                            executable.exec(bash);
                        }
                        
                        if (typeof href !== 'undefined') {
                            executable.exec('xdg-open '+model.href);
                        }
                        
                        if (typeof refresh !== 'undefined' && refresh == 'true') {
                            root.update();
                        }
                    }
                }
            }
            
            // expand-collapse icon
            PlasmaCore.IconItem {
                id: arrow_icon
                source: (fullRoot.categories[itemLabel.text] !== undefined && fullRoot.categories[itemLabel.text].visible) ? 'arrow-down': 'arrow-up'
                visible: (typeof category === 'undefined' && fullRoot.categories[itemLabel.text] !== undefined && fullRoot.categories[itemLabel.text].items.length > 0) ? true:false
                
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                            
                        // toggle childs visible
                        fullRoot.categories[itemLabel.text].rows.forEach(function(row) {
                            if (row.visible === true) {
                                row.visible = false;
                                row.height = 0;
                            } else {
                                row.visible = true;
                                row.height = row.visibleHeight;
                            }
                        });
                        
                        fullRoot.categories[itemLabel.text].visible = !fullRoot.categories[itemLabel.text].visible;
                        arrow_icon.source = arrow_icon.source === 'arrow-up'? 'arrow-down': 'arrow-up' 
                        
                    }
                }
            }  
        }
    }
    
    Connections {
        target: executable
        onExited: {
                if (sourceName === plasmoid.configuration.command) {
                    update(stdout);
                }
        }
    }
    
    function update(stdout) {
        kargosModel.clear();
        
        var items = parseItems(stdout);
        
        items.forEach(function(item) {
            if (item.category !== undefined) {
                if (fullRoot.categories[item.category] === undefined) {
                    fullRoot.categories[item.category] = {visible : false, items: [], rows: []};
                }
                if (item.category !== undefined) {
                    fullRoot.categories[item.category].items.push(item);
                }
            }
        });
        
        items.forEach(function(item) {
            kargosModel.append(item);
            
        });
    }
    
    function updateWidth() {
        var max = -1;
        
        for(var child in listView.contentItem.children) {
            
            if (listView.contentItem.children[child].width > max) {
                max = listView.contentItem.children[child].width;
            }
        }
        
        if (max > 0) {
            fullRoot.Layout.preferredWidth = max;
        }
    }
}

