load(arguments[0]);
bootstrap(arguments[1]);
plan(2);
test("Check that debug screen!", function() {
    expect(2);
    var e = document.getElementById('appname');
    equals(e.innerHTML, "t::TestApp");
    equals(e.innerHTML, "t::TestApp", "with a name");
});
