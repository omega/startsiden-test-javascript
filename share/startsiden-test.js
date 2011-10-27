/* We want to be able to look in different places! */
var args = phantom.args.slice(0);
var test_script = args.shift();
var inc, input;
args.forEach(function(e) {
    if (e.match(/^INC/)) {
        inc = e.split(':');
    } else {
        input = e;
    }
});

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


if (input) {
    //console.log("Requesting page " + input);
    page.open(input, function(status) {
        //console.log("STATUS: " + status);
        if (status !== "success") {
            console.log("# (" + status + ") Unable to access requested document " + input);
            phantom.exit(1);
        } else {
            //console.log("loading qunit " + page);
            load("qunit.js", page);
            //console.log("loading qunit-tap");
            load("qunit-tap.js", page);
            //console.log("done loading qunit-stuff");
            page.evaluate(function() {
                window.plan = function(n) {
                    console.log("1.." + n);
                    QUnit.tap.noPlan = false;
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
                qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {
                    noPlan: true
                });
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
            //console.log("injecting " + test_script);

            page.injectJs(test_script);

            waitFor(function() {
                return page.evaluate(function() {
                    //console.log(window.tests + " " + window.modules);
                    return (window.tests == 0 && window.modules <= 0);
                });
            }, function() {
                //console.log("in another function");
                phantom.exit();
            }, 15000);
        }
    });
}
