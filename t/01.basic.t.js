load("startsiden-test.js");
plan(1);
bootstrap(arguments[0]);

test("Finding class name works", function() {
    expect(1);
    var s = document.getElementById('search');
    equals("hidden", s.className);
});

