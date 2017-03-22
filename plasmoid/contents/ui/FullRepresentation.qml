import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

Item {
    id: fullRoot
    
    Layout.preferredWidth: plasmoid.configuration.width
    
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
        
        delegate: Row {
            id: row
            height: (typeof category === 'undefined' || (fullRoot.categories[category].visible)) ? row.visibleHeight: 0
            visible: (typeof category === 'undefined') ? true : (fullRoot.categories[category].visible)
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
                text: fullRoot.createTitleText(model);
                wrapMode: Text.WordWrap
                width: fullRoot.width - arrow_icon.width - 30//some right margin
                
                Component.onCompleted: {
                    if (typeof model.font !== 'undefined') {
                        font.family = model.font;
                    }
                    if (typeof model.size !== 'undefined') {
                        font.pointSize = model.size;
                    }
                }
            
                MouseArea {
                    cursorShape: (typeof model.bash!=='undefined'|| typeof model.href !== 'undefined' || typeof model.refresh !== 'undefined') ? Qt.PointingHandCursor: Qt.ArrowCursor
                    anchors.fill: parent
                
                    onClicked: {
                        if (typeof model.bash !== 'undefined') {                         
                            executable.exec(model.bash);
                        }
                        
                        if (typeof model.href !== 'undefined') {
                            executable.exec('xdg-open '+model.href);
                        }
                        
                        if (typeof model.refresh !== 'undefined' && model.refresh == 'true') {
                            root.update();
                        }
                    }
                }
            }
            
            // expand-collapse icon
            PlasmaCore.IconItem {
                id: arrow_icon
                source: (fullRoot.categories[model.title] !== undefined && fullRoot.categories[model.title].visible) ? 'arrow-down': 'arrow-up'
                visible: (typeof model.category === 'undefined' && fullRoot.categories[model.title] !== undefined && fullRoot.categories[model.title].items.length > 0) ? true:false
                
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                       // In order to notify binding of fullRoot.categories property, we clone it, and then reassign it.
                       var newState = fullRoot.copyObject(fullRoot.categories);
                       newState[model.title].visible = !newState[model.title].visible
                       
                       fullRoot.categories = newState;
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
    
    function copyObject(object) {
        var copy = {};
            
        Object.keys(object).forEach(function(prop) {
            copy[prop] = object[prop];
            
        });
        
        return copy;
    }
    
    function createTitleText(item) {
        var titleText = '<div>'+item.title.replace(/\\n/g, '<br>').replace(/  /g, '&nbsp;&nbsp;') + '</div>';
        
        return titleText;
        
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
    
    /*function updateWidth() {
        var max = -1;
        
        for(var child in listView.contentItem.children) {
            
            if (listView.contentItem.children[child].width > max) {
                max = listView.contentItem.children[child].width;
            }
        }
        
        if (max > 0) {
            fullRoot.Layout.width = max;
        }
    }*/
}

