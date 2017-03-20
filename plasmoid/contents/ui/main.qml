import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrolsaddons 2.0


Item {
    id: root
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}
    
    property int interval;    
    property int currentItemsInCommand;
    
    Component.onCompleted: { 
        currentItemsInCommand = 0;
        
        //first update
        update();
        
        timer.running = true;
    }

    function update() {
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
        }
    }
    
    
    function parseLine(line) {
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
        return parsedObject;
    }

    
    function parseItems(stdout) {
        var items = [];
        
        var menuGroupsStrings = stdout.split("---");
        
        var totalItems = 0;
        if (menuGroupsStrings.length > 1) {
            
            for (var i = 1; i < menuGroupsStrings.length; i++) {
                var groupString = menuGroupsStrings[i];
                
                var groupTokens = groupString.trim().split('\n');
                groupTokens.forEach(function (groupToken) {                
                    var parsedItem = root.parseLine(groupToken);
                   // console.log('adding '+JSON.stringify(parsedItem));
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
        }
    }
    
    Timer {
        id: timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: update()
    }    
}