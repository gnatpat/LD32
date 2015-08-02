var net = require('net');
var policy = net.createServer(function(c) {
    console.log(c.remoteAddress + ":" + c.remotePort + " connected...");
    c.on('data', function(data) {
        if(data == "<policy-file-request/>\0") 
        {
            c.write('<?xml version="1.0"?>'+
                '<cross-domain-policy>'+
                '<allow-access-from domain="*" to-ports="*"/>'+
                '</cross-domain-policy>\0');
            console.log("Actually sent one.");
        }
   });
});

policy.listen(843, function() {
    console.log("Policy server started.");
});

policy.on('error', function(e) {
    console.log(e);
});

/*http = require('http');

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/x-cross-domain-policy'});
    res.end('<?xml version="1.0"?>'+
                '<cross-domain-policy>'+
                '<site-control permitted-cross-domain-policies="by-content-type"/>'+
                '<allow-access-from domain="*"/>'+
                '</cross-domain-policy>');
}).listen(843);
console.log("Server running..\n");*/
