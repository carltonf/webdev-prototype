var $ = require('jquery');

console.log('jQuery version: "' + $.fn.jquery + '" loaded');

$(function(){
  $('body')
    .append('<h1>Hi</h1>')
    .append('<h2>there</h2>')
    .append('<h3>here</h3>')
    .append('<p>Hello <mark>Browserify</mark></p>');
});

window.replmy = { doc: "test replmy object for passing callables." };
// I just try to change something, hooj
