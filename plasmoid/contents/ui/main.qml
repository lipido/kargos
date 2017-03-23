import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: root
    
    Plasmoid.preferredRepresentation: isConstrained() ? Plasmoid.compactRepresentation : Plasmoid.fullRepresentation

    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}
    
    property int interval;    
    property int currentItemsInCommand;
    
    function isConstrained() {
        return (plasmoid.formFactor == PlasmaCore.Types.Vertical || plasmoid.formFactor == PlasmaCore.Types.Horizontal);
    }

    Component.onCompleted: {        
        timer.running = true;        
    }
    
    function update() {
        currentItemsInCommand = 0;
        executable.exec(plasmoid.configuration.command);
        updateInterval();
    }
    
    function updateInterval() {
        var commandTokens = plasmoid.configuration.command.split('.');
            
        if (commandTokens.length >= 3) {
            var intervalToken = commandTokens[commandTokens.length - 2]; //ex: 1s
            
            
            if (/^[0-9]+[smhd]$/.test(intervalToken)) {
                var lastChar = intervalToken.charAt(intervalToken.length-1);
                switch (lastChar) {
                    case 's': timer.interval = parseInt(intervalToken.slice(0, -1)) * 1000; break;
                    case 'm': timer.interval = parseInt(intervalToken.slice(0, -1)) * 1000 * 60; break;
                    case 'h': timer.interval = parseInt(intervalToken.slice(0, -1)) * 1000 * 3600; break;
                    case 'd': timer.interval = parseInt(intervalToken.slice(0, -1)) * 1000 * 3600 * 24; break;
                }
            }
        } else {
            timer.interval = plasmoid.configuration.interval * 1000
        }
    }
    
    
    function parseLine(line, currentCategory) {
        var parsedObject = {title: line};
        
        if (line.indexOf('|') != -1) {
            parsedObject.title = line.split('|')[0].trim();
            
            var attributesToken = line.split('|')[1].trim();
            
            attributesToken.split(" ").forEach(function(attribute_value) {
                
                if (attribute_value.indexOf('=')!=-1) {
                    parsedObject[attribute_value.split('=')[0]] = attribute_value.split('=')[1];
                }
            });
        }
        
        
        if (parsedObject.title.match(/^--/)) {
            parsedObject.title = parsedObject.title.substring(2).trim();
            if (currentCategory !== undefined) {
                parsedObject.category = currentCategory;
            }
        }
        return parsedObject;
    }
    
    function parseItems(stdout) {
        var items = [];
        var currentCategory = null;
        
        var menuGroupsStrings = stdout.split("---");
        
        var totalItems = 0;
        if (menuGroupsStrings.length > 1) {
            
            for (var i = 1; i < menuGroupsStrings.length; i++) {
                var groupString = menuGroupsStrings[i];
                
                var groupTokens = groupString.trim().split('\n');
                groupTokens.forEach(function (groupToken) {                
                    var parsedItem = root.parseLine(groupToken, currentCategory);
                    if (parsedItem.category === undefined) {
                        currentCategory = parsedItem.title;
                    }
                    items.push(parsedItem);
                    totalItems ++;
                    
                });                
            }            
        }
        return items;
    }
    
    // Object to run commands
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
                var stdout = data["stdout"]
                exited(sourceName, stdout)
                disconnectSource(sourceName) // cmd finished
        }
        
        function exec(cmd) {
                connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)

    }
    
    Connections {
        target: executable
        onExited: {
                currentItemsInCommand = parseItems(stdout).length
                if (stdout.indexOf('---') === -1) {
                    plasmoid.expanded = false
                }
        }
    }
    
    Timer {
        id: timer
        interval: plasmoid.configuration.interval * 1000
        running: false
        repeat: true
        onTriggered: update()
    }    
}