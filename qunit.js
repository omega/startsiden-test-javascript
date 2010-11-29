load("../qunit/qunit/qunit.js");
load("../qunit-tap/lib/qunit-tap.js");

QUnit.init();
QUnit.config.blocking = false;
QUnit.config.autorun = true;
QUnit.config.updateRate = 0;

function plan(n) {
    print("1.." + n);
}
function diag(msg) {
    print("# " + msg);
}

function bootstrap(file) {
    load("../env-js/dist/env.rhino.js");
    Envjs({
        log: function(string) {
            diag(string);
        },
        scriptTypes: {
             '': true,
            'text/javascript': true,
        },
    });
    window.location = file;
}

