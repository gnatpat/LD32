var net = require('net');

var connections = [];
var currentMap;
var hasMap = false;
var nextID = 0;

var server = net.createServer();

server.listen(8124, function() {
    console.log('server bound');
});

server.on('connection', function(c) {
    c.name = c.remoteAddress + ':' + c.remotePort;
    c.id = nextID++;
    c.started = false;
    c.info = "";
    console.log('Client connected: ' + c.name + ' with id ' + c.id);  
    c.write("W" + c.id + "\n");

    if(hasMap)
        c.write('M' + currentMap + '\n');
    else
        c.write('S' + '\n');

    connections.forEach(function (client) {
        c.write('N' + client.id + '\n');
        if(client.started)
            c.write('U' + client.id + ":" + client.info + '\n');
    });
    broadcast('N' + c.id + '\n', c);
    
    connections.push(c);
    
    c.on('data', function (data) {
        datas = data.toString().split("\n");
        datas.forEach(function(data)
        {
            if(data.charAt(0) == 'M')
            {
                console.log("Got new map.");
                currentMap = data.slice(1);
                hasMap = true;
                broadcast('M' + currentMap + '\n', c);
            }
            if(data.charAt(0) == 'U')
            {
                var newInfo = data.slice(1);
                c.info = newInfo;
                c.started = true;
                broadcast('U' + c.id + ":" + newInfo + '\n', c);
            }
        });
    });

    c.on('end', function() {
        console.log('Client disconnected: ' + c.name);
        connections.splice(connections.indexOf(c), 1);
        broadcast("L" + c.id + "\n", c);
    });

    function broadcast(message, sender) {
        connections.forEach(function (client) {
            if (client === sender) return;
            client.write(message);
        });
    }

    c.on('error', function(e) {
        console.log("Error. " + e);
    });
});

