var menu;

function createMouseArea(parent) {
     return Qt.createQmlObject('import QtQuick 2.0; import QtQuick.Controls 1.4; MouseArea {anchors.fill : parent}', parent);
    
}

function createRootMenu(parent) {
    return Qt.createQmlObject('import QtQuick 2.0; import QtQuick.Controls 1.4; Menu {}', parent);
}   


function createMenu(parent) {
    
    menu = createRootMenu(parent);
    var mouseArea = createMouseArea(parent);
    
    mouseArea.clicked.connect(function() {
        menu.popup();
    });
    
}

function createMenuItems(plugin_output) {
    clearMenuItems(); // TODO: Better menu item re-render, reuse existing menuitems
    var menuGroupsStrings = plugin_output.split("---");
    
    if (menuGroupsStrings.length > 1) {
        
        for (var i = 1; i < menuGroupsStrings.length; i++) {
            var groupString = menuGroupsStrings[i];
            
            var groupTokens = groupString.trim().split('\n');
            groupTokens.forEach(function (groupToken) {                
                var parsedItem = parseLine(groupToken);
                
                var menuItem = menu.addItem(parsedItem.text.replace(/\\n/g, "<br>"));
                
                if (parsedItem.size !== undefined) {
                    console.log('changing size');
                    menuItem.text = '<font size="'+parsedItem.size+'">'+parsedItem.text+'</font>';
                }
                
                if (parsedItem.iconName !== undefined) {
                    menuItem.iconName = parsedItem.iconName; // it doesn't work (qtquick bug?)
                }
                
             
                menuItem.triggered.connect(function() {
                    console.log('click in '+parsedItem.text);
                    
                    if (parsedItem.bash !== undefined) {
                        executable.exec(parsedItem.bash);
                    }
                    
                    if (parsedItem.href !== undefined) {
                        executable.exec('xdg-open '+parsedItem.href);
                    
                    }
                });
            });
        }
    }
    
}

/**
 * Parses the the line following the Argos convention https://github.com/p-e-w/argos#output-format
 */
function parseLine(line) {
    var parsedObject = {text: line};
    
    if (line.indexOf('|') != -1) {
        
        parsedObject.text = line.split('|')[0].trim();
        
        var attributesToken = line.split('|')[1].trim();
        
        attributesToken.split(" ").forEach(function(attribute_value) {
            
            if (attribute_value.indexOf('=')!=-1) {
                parsedObject[attribute_value.split('=')[0]] = attribute_value.split('=')[1];
            }
        });
    }
    return parsedObject;
}

function clearMenuItems() {
    for (var i = menu.items.length - 1; i >= 0; i--) {
        menu.removeItem(menu.items[i]);
    }
}