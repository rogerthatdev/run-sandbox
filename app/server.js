// sidecar

'use strict';

const express = require('express');

// Constants
const PORT = 8888;
const HOST = '0.0.0.0';

// App
// todo: serve up an index.html file
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
  
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});