# Testing javascript in webpages

So, the problem we are always facing.. How do we test javascript? and user
interface javascript at that?

This attempt at a solution uses Rhino to load webpages, and execute any javascript
in there, giving you a DOM to work with and check, triggering events on etc.

## Give me the gist of it

Well, we provide a simple perl-function to run a javascript file
against a content-string. That way, so long as you can get the content in a perl
scalar, you can run javascript against it. You can for instance use
Catalyst::Test, or Test::WWWW::Mechanize::Catalyst to do that, without needing to
fork a server etc.

## How do I test it?

There are a few things you need:

* Working Mozilla rhino
* clones or downloads of QUnit, qunit-tap and env.js
* a `JSINC` env var that points to directories containing the aforementioned files

### rhino

Well, you need rhino set up. You also need an executable script somewhere in your
`PATH` called rhino. Mine looks like this:

    #!/bin/bash
    java -cp ~/Projects/js/rhino/js.jar org.mozilla.javascript.tools.shell.Main -opt -1 $@

### QUnit

I just cloned it to `~/Projects/js/qunit/`, and added `~/Projects/js/qunit/qunit` to
my `JSINC`.

### qunit-tap

I cloned this as well to `~/Projects/js/qunit-tap`, and added
`~/Projects/js/qunit-tap/lib` to my `JSINC

### env.js

Envjs is a bit more pain, unless you just download env.rhino.1.2.js from
[envjs.com/](http://www.envjs.com/dist/env.rhino.1.2.js) and put it somewhere in
your `JSINC`.

*note*: You need to call the file `env.rhino.js`, without the version-info

You can also opt to clone from github, but then you need to compile the `env.rhino.js`

I cloned to `~/Projects/js/env-js`, and added `~/Projects/js/env-js/dist` to my JSINC.

## I got all that installed, now what?

Once that is in place, you should be able to run prove in the normal way.

    prove -l t/

If all goes well, you should see the regular test output!

## Whoa, cool, can I do that with my app?

I sure hope so! Thats the point at least :p The perl-module
`Startsiden::Test::JavaScript` only really provides two functions. `js_test`
and `js_live_test`. The later does a lot more than the first one, so lets cover
the first one first!

### js_test

`js_test` can be run in two different ways:

    use Startsiden::Test::JavaScript;
    js_test

and

    use Startsiden::Test::JavaScript;
    js_test '<html><body><h1>This is some content</h1></body></html>'

The difference is that the second one will write the content to a temp-file,
and pass that on to the javascript part of the test.

Lets say we named this file `t/01.basic.t` for instance. Then we would also
create a `t/01.basic.t.js`, which will hold our javascript part of the test:

    load(arguments[0]); // 0 is always the location of startsiden-test.js
    bootstrap(arguments[1]);

    plan(1);
    test("Finding class name works", function() {
        expect(1);
        var s = document.getElementById('search');
        equals("hidden", s.className);
    });

There is a couple of lines of boilerplate at the top, which is hard to avoid
for now :/ The first one loads our test-lib, which defines some of the other
functions we use (namely bootstrap, plan and diag. It also provides console.log
for code that uses that).

The second one loads env-js, and tells env.js where to find our content (the
string we passed to `js_test` earlier, remember?)

Then we let it know how many tests we plan to run, before we run some QUnit
tests.

As you can see, this test has access to the DOM of the content we passed it.
*That is a cool thing* :)


### js_live_test

Then `js_live_test` comes along! Changing the game completely! How you say? By
making things easy to test _live_:

Again, the Perl-portion of the test is simple. Consider the folowing in
`t/03.ajax.t`:

    use Startsiden::Test::JavaScript;
    js_live_test cat => 't::TestApp' => '/ajax';

Quite simple ehh? Let me explain: First we have a flag for app-type. For now we
only support cat, but implementing PSGI for instance should be a breeze, since
we already use Plack::Test for actually running the Cat-app :p

Then we can look at the javascript part again, in `t/03.ajax.t.js`:

    load(arguments[0]);
    bootstrap(arguments[1]);
    plan(1);
    $('#button2').click();
    test("For real, check the ajax!", function() {
        stop();
        expect(1);
        var t = setTimeout(function() {

            equals($('#content').html(), 'C', "and then to C in ajax call");
            start();
        }, 1000);
    });

    Envjs.wait();

As we can see here, it gets a bit more complicated, but not overly so I think!
Before we go on, let us also take a moment to look at the content that we run
this test against (What `/ajax` of `t::TestApp` returns):


    <html>
        <head>
            <script type="text/javascript" src="/static/jq.js"></script>
            <script type="text/javascript">
                $().ready(function() {
                    // lets try to replace some content as well!
                    $('#button2').click(function() {
                        $('#content').load('/new');
                    });
                });
            </script>
        </head>
        <body>
            <div id="content">a</div>
            <button id="button2">Click me!</button>
        </body>
    </html>

You see it links to `jquery` for instance, and then uses that in the next
script-tag.

If we return to the interesting part of our `t/03.ajax.t.js` (I skipped the
boilerplate):

    $('#button2').click();
    test("For real, check the ajax!", function() {
        stop();
        expect(1);
        var t = setTimeout(function() {

            equals($('#content').html(), 'C', "and then to C in ajax call");
            start();
        }, 1000);
    });

    Envjs.wait();

If we start from the top, we see that we now have access to jquery from our
test as well, since our test-page loads it. This makes it easy to write your
tests in whatever javascript-library you usually use. The only thing we always
load is `QUnit` and `qunit-tap`.

Line 1 simply simulates a click of a button. Then comes our qunit-test, which
uses the async-capabilities of qunit (the `stop()` and `start()` functions).
You see we also do a setTimeout. This is to give our DOM time to change, since
AJAX is by definition Async.

On the last line, we see a call to `Envjs.wait()`, which we have to do to make
sure our timeout gets run.

*And there you have it, all summed up nicely!*
