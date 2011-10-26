/* We want to be able to look in different places! */

var inc = phantom.args[2].split(':');
var fs = require('fs');

function load(lib, into) {
    //console.log("looking for " + lib);
    // Blah, this is probably not cool
    inc.forEach(function(path) {
        var test = path + fs.separator + lib;
        //console.log("  -> " + test);
        if (fs.isFile(test)) {
            //console.log("    -> FOUND");
            into.injectJs(test);
        }
    });
}
function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 3001, //< Default Max Timout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    // console.log("'waitFor()' timeout");
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    // console.log("'waitFor()' finished in " + (new Date().getTime() - start) + "ms.");
                    typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 100); //< repeat check every 250ms
};



if (typeof(console) == "undefined") {
    console = {};
    console.log = function() {
        print(arguments);
    }
}



/* lets run the test */


var page = require('webpage').create();


page.onConsoleMessage = function(msg) {
    console.log(msg);
};

var file = phantom.args[1];

if (file) {
    page.open(file, function(status) {
        if (status !== "success") {
            console.log("# (" + status + ") Unable to access requested document " + file);
            phantom.exit(1);
        } else {

            load("qunit.js", page);
            load("qunit-tap.js", page);
            page.evaluate(function() {
                window.plan = function(n) {
                    console.log("1.." + n);
                }
                window.diag = function(msg) {
                    console.log("# " + msg);
                }
                window.addListener = function(target, name, func) {
                    if (typeof target[name] === 'function') {
                        var orig = target[name];
                        target[name] = function() {
                            var args = Array.prototype.slice.apply(arguments);
                            orig.apply(target, args);
                            func.apply(target, args);
                        };
                    } else {
                        target[name] = func;
                    }
                };

                QUnit.init();
                QUnit.config.blocking = false;
                QUnit.config.autorun = true;
                QUnit.config.updateRate = 0;
                qunitTap(QUnit, function() { console.log.apply(console, arguments); });
                window.modules = 0;
                window.tests = 0;

                addListener(QUnit, 'moduleStart', function() {
                    window.modules++;
                });
                addListener(QUnit, 'moduleDone', function() {
                    window.modules--;
                });
                addListener(QUnit, 'testStart', function() {
                    window.tests++;
                });
                addListener(QUnit, 'testDone', function() {
                    window.tests--;
                });

            });

            page.injectJs(phantom.args[0]);

            waitFor(function() {
                return page.evaluate(function() {
                    //console.log(window.tests + " " + window.modules);
                    return (window.tests == 0 && window.modules == 0);
                });
            }, function() {
                //console.log("in another function");
                phantom.exit();
            });
        }
    });
}
