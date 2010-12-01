/* We want to be able to look in different places! */
var inc = new Array();

init_inc(inc);

safe_load("qunit.js");
safe_load("qunit-tap.js");

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
    safe_load("env.rhino.js");
    Envjs({
        log: function(string) {
            diag(string);
        },
        scriptTypes: {
             '': true,
            'text/javascript': true,
        },
    });
    if (typeof(Envjs.alert) == "undefined") {
        window.displayedAlert = '';
        // XXX: A Bug in Envjs makes us need to do this:
        // http://envjs.lighthouseapp.com/projects/21590-envjs/tickets/182-envrhino12-calling-alert-throws-exception-cannot-find-function-alert-in-objec
        Envjs.alert = function(string) {
            displayedAlert = string;
        };
    };
    if (file) {
        window.location = file;
    }
}
function init_inc(inc) {
    // What do we have here?
    var cp = environment['java.class.path'];
    // java.class.path: /Users/andremar/Projects/js/rhino/js.jar
    if (cp.match('/usr/local/share/rhino')) {
        // XXX: I hate hardcoding these, but blah!
        inc.push('/usr/local/share/startsiden-javascript-qunit');
        inc.push('/usr/local/share/startsiden-javascript-envjs');
    }

    var paths = getinc();
    for (i in paths) {
        inc.push(paths[i]);
    }
}
function safe_load(lib) {
    var found = 0;
    for (dir in inc) {
        // Need to check if our lib exists here
        // XXX: Not working on windows with the whole / biz
        dir = inc[dir];
        if (!dir.match(environment['file.separator'] + "$")) {
            dir = dir + environment['file.separator'];
        }
        var file = dir + lib;

        if (!runCommand("test", "-f", file)) {
            found++;
            load(file);
            break;
        }
    }
    if (found == 0) {
        print("Could not find " + lib + " in our INC(" + inc.join(":") + ")");
    } else if (found > 1) {
        print("We found more than one version of "
                + lib + " in our INC(" + inc.join(":") + ")");
    }
}
function getinc() {
    var path = getenv("JSINC");
    return path.split(':');
}
function getenv(key) {
    var opt = {'output': ''};
    // XXX: does not work on windows!
    if (environment['os.name'].match('Mac OS X|Linux')) {
        runCommand('printenv', key, opt);
        print(opt.output);
    } else {
        print("Unsupported os.name: " + environment['os.name']);
        quit();
    }
    var out = opt.output.replace("\n", "");
    return out;
}
