var assert = require('assert');

describe("Basic arith", function(){
  it("1 + 1 = 2", function(){
    assert.equal(1+1, 2)
  });

  it("1 + 3 = 4", function(){
    assert.equal(1 + 3, 4);
  });
});

describe("Inspect page", function(){
  it("Title contains Web Development", function(){
    var title = document.querySelector('title').textContent;
    assert.ok(title.includes('Web Development'));
  });

  it("Existing h1 shows Demo Page", function(){
    var pageTitle = document.querySelector('body > h1').textContent;
    assert.ok(pageTitle.includes('Demo Page'));
  });
});
