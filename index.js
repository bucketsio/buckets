var express = require('express');
var logfmt  = require('logfmt');

var app = express();

app.use(logfmt.requestLogger());

app.get('/', function(request, response) {
  response.sendfile(__dirname + '/index.html')
});

app.listen(Number(process.env.PORT));
