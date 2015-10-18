// To be dynamically loaded after the page is fully loaded.

var xhr = new XMLHttpRequest();
xhr.open('GET', '/tools/test/page-snippet.html', true);
xhr.responseType = 'document';
xhr.onload = function(e) {
  var doc = e.target.response;

  [].forEach.call(doc.body.children, function(art){
    document.body.appendChild(art);
  });

  loadFilesInOrder(
    '/bundle/test.css',
    "/node_modules/mocha/mocha.js",
    "/tools/test/mocha-config.js",

    /**
     * all other css and js are just infrastructure, test scripts are all
     * bundled into single test.js
     */
    "/bundle/test.js",

    "/tools/test/mocha-run.js"
  ).then(function(){
    console.log("Test page loaded and tests done !");

    // Reconfirm the location hash as :target doesn't seem to be stable
    // when the DOM of the main page changes.
    window.location.hash = "#mocha-page-modal";
  });
};
xhr.send();

// TODO this loading facility feels more generic worthy for an separate module
//
// Load files in order, return a Promise that promises all files will pass in
// that order.
function loadFilesInOrder(){
  var files = arguments;
  var loadPromise = null;

  return [].reduce.call(
    files,
    function(chainedPromise, fname){
      return chainedPromise.then(function(){
        return loadjscssfile(fname);
      });
    },
    // stub start promise
    Promise.resolve(true)
  );
}

// filetype and callback is optional
// when callback is omitted , a Promise is returned.
function loadjscssfile(filename, filetype, callback){
  if (!filetype){
    filetype = filename.slice(filename.lastIndexOf('.') + 1);
  }
  var fileref = null;

  switch (filetype) {
  case "js":
    fileref = document.createElement('script');
    fileref.setAttribute("src", filename);
    break;
  case "css":
    fileref = document.createElement("link");
    fileref.setAttribute("rel", "stylesheet");
    fileref.setAttribute("href", filename);
    break;
  default:
    return false;
  }

  if (typeof fileref != "undefined"){
    document.body.appendChild(fileref)
  }

  // optionally return a Promise
  if(typeof callback === "function"){
    fileref.onload = callback;
    return;
  }
  else {
    return new Promise(function(resolve, reject){
      fileref.onload = resolve;
    });
  }
};
