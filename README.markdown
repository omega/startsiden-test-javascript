# Testing javascript in webpages

So, the problem we are always facing.. How do we test javascript? and user
interface javascript at that?

In this new re-write we use PhantomJS, a headless WebKit, to provide us access
to a propper DOM etc.

## Give me the gist of it

Well, we provide a simple perl-function to run a javascript file
against a content-string. That way, so long as you can get the content in a perl
scalar, you can run javascript against it. You can for instance use
Catalyst::Test, or Test::WWW::Mechanize::Catalyst to do that, without needing to
fork a server etc.

## How do I test it?

There are a few things you need:

* Working PhantomJS
* clones or downloads of QUnit and qunit-tap.
* a `JSINC` env var that points to directories containing the aforementioned files

### PhantomJS

For Mac OS X, a simple `brew install phantomjs` will do. For other platforms,
there might be differences.

### QUnit

Caution: This QUnit-TAP does not work with QUnit `1.11.0` or above. Please stick with `1.10.0` until QUnit-TAP get an update.

https://github.com/jquery/qunit

I just cloned it to `~/Projects/js/qunit/`, and do `git checkout v1.10.0` then add `~/Projects/js/qunit/qunit` to
my `JSINC`.

### qunit-tap

https://github.com/twada/qunit-tap

I cloned this as well to `~/Projects/js/qunit-tap`, and added
`~/Projects/js/qunit-tap/lib` to my `JSINC`

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

`js_test` can be run in three different ways:

    use Startsiden::Test::JavaScript;
    js_test

and

    use Startsiden::Test::JavaScript;
    js_test '<html><body><h1>This is some content</h1></body></html>'

and

    use Startsiden::Test::JavaScript;
    js_test 't/html/test.html'

The first one will have no HTML loaded into the DOM, but should still execute
your javascript in a good environment.

The second will write the string to a tempfile, and use that as your web page.

The third one will load the given file as your webpage.

Lets say we named this file `t/01.basic.t` for instance. Then we would also
create a `t/01.basic.t.js`, which will hold our javascript part of the test:

    plan(1);
    test("Finding class name works", function() {
        expect(1);
        var s = document.getElementById('search');
        equals("hidden", s.className);
    });

We let it know how many tests we plan to run, but this is optional. The tests
are written using QUnit, but in the background we use Qunit-tap to provide us
with TAP output.

As you can see, this test has access to the DOM of the content we passed it.
*That is a cool thing* :)


### js_live_test

Then `js_live_test` comes along! Changing the game completely! How you say? By
making things easy to test _live_:

Again, the Perl-portion of the test is simple. Consider the folowing in
`t/03.ajax.t`:

    use Startsiden::Test::JavaScript;
    js_live_test cat => 't::TestApp' => '/ajax';

Quite simple ehh? Let me explain: First we have a flag for app-type. We support
two types at the moment, one being `cat` for Catalyst apps, the other being
`psgi` for PSGI-apps.

The `cat` type will load the class, then enable the PSGI-engine on it, and get
a PSGI-app out of that, while the `psgi` type will just load a psgi-file:

    use Startsiden::Test::JavaScript;
    js_live_test psgi => 'app.psgi' => '/';

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

If we return to the interesting part, our `t/03.ajax.t.js`:

    $('#button2').click();
    test("For real, check the ajax!", function() {
        stop();
        expect(1);
        var t = setTimeout(function() {

            equals($('#content').html(), 'C', "and then to C in ajax call");
            start();
        }, 1000);
    });

If we start from the top, we see that we now have access to jquery from our
test as well, since our test-page loads it. This makes it easy to write your
tests in whatever javascript-library you usually use. The only thing we always
load is `QUnit` and `qunit-tap`.

Line 1 simply simulates a click of a button. Then comes our qunit-test, which
uses the async-capabilities of qunit (the `stop()` and `start()` functions).
You see we also do a setTimeout. This is to give our DOM time to change, since
AJAX is by definition Async.

*And there you have it, all summed up nicely!*

### Karma

In addition to the above methods, now you can your tests with Karma runner and PhantomJS. So you will need to following to make in work both on your machine and on the Builder.

* Working PhantomJS.
* `python` and `startsiden-nodejs` Debian packages are required in `Makefile.PL`.
* If you have `bower.json` and `package.json`, they must be in the root folder of your project.

Then, you can just create a test file that is similar to the following one.
    
    use Startsiden::Test::JavaScript;
    
    my $args = {
        # Optional Karma configuration path if it is not Karma.conf.js
        karmaConfPath => 't/07.karma.t.conf.js'
    };

    js_karma_test $args;
    
This is how it works right now.

* Install `bower` and `karma-cli` NPM packages if they have not been installed yet.
* Resolve Bower and NPM dependencies if `bower.json` and `package.json` exist.
* Install `karma-tab-reporter` NPM package (a Karma plugin used to produce the TAP report) from the `share` folder.
* Run Karma with options `--single-run --browsers PhantomJS --reporters tap --log-level LOG_DISABLE`.