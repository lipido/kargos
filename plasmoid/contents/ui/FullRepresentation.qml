import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

Item {
    id: fullRoot
    Layout.preferredWidth: 1//this value 
    
    ListModel {
        id: kargosModel
    }
    
    Component.onCompleted: { 
        //first update
        root.update();     
    }
    
    ListView {        
        id: listView
        anchors.fill: parent
        model: kargosModel
        add:{
            updateWidth()
        }
        delegate: Row {
            
            PlasmaCore.IconItem {
                source: iconName
                    
            }            
            PlasmaComponents.Label {
                
                text: title.replace(/\\n/g, "<br>")
                MouseArea {
                    cursorShape: (typeof bash!=='undefined'|| typeof href !== 'undefined' || typeof refresh !== 'undefined') ? Qt.PointingHandCursor: Qt.ArrowCursor
                    anchors.fill: parent
                
                    onClicked: {
                        console.log('clicked ');
                        
                        if (typeof bash !== 'undefined') {                         
                            executable.exec(bash);
                        }
                        
                        if (typeof href !== 'undefined') {
                            executable.exec('xdg-open '+model.href);
                        
                        }
                        
                        if (typeof refresh !== 'undefined' && refresh == 'true') {
                            console.log('refreshing');
                            root.update();
                        }
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
            kargosModel.append(item);
            
        });
    }
    
    function updateWidth() {
        var max = -1;
        for(var child in listView.contentItem.children) {
            console.log('bla: '+listView.contentItem.children[child].width);
            if (listView.contentItem.children[child].width > max) {
                max = listView.contentItem.children[child].width;
            }
            
        }
        if (max > 0) {
            console.log('setting max to '+max);
            fullRoot.Layout.preferredWidth = max;
        }
    }
}

