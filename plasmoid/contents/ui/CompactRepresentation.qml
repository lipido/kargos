import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "componentCreation.js" as ComponentCreation
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaComponents.Label {
    
    id: root
    text: "starting..."
    
    Layout.preferredWidth: root.implicitWidth
    
    property int interval;
    
    Component.onCompleted: { 
 
        ComponentCreation.createMenu(root);
        
        //first update
        updateMenuItems();
        
        // start interval        
        timer.interval = 1000; //default interval
        timer.running = true;
    }
 
    
    Timer {
        id: timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: updateMenuItems()
    }
    
    // Object to run commands
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
                var stdout = data["stdout"]
                //exited(exitCode, exitStatus, stdout, stderr)
                if (callbacks[sourceName]) {
                    callbacks[sourceName](stdout);
                }
                disconnectSource(sourceName) // cmd finished
        }
        property var callbacks: ({})
        function exec(cmd, callback) {
                
                if (callback!==undefined) {
                    callbacks[cmd] = callback;
                }
                connectSource(cmd)
        }
    }
    
    function updateMenuItems() {
            updateInterval();
            
            executable.exec(plasmoid.configuration.command, function(stdout) {
                root.text = ComponentCreation.parseLine(stdout.split('\n')[0]).text;
                ComponentCreation.createMenuItems(stdout);
                
            });
        
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
    
}

    
   