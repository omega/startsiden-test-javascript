load(arguments[0]); // 0 is always the location of startsiden-test.js
plan(1);
bootstrap(arguments[1]);

test("Finding class name works", function() {
    expect(1);
    var s = document.getElementById('search');
    equals("hidden", s.className);
});

