var $ = require('jquery');

console.log('jQuery version: "' + $.fn.jquery + '" loaded');

$(function(){
  $('body')
    .append('<h1>Demo for bundled Script</h1>')
    .append('<p>Use live reloading with <strong>Browserify</strong>!</p>');
});

