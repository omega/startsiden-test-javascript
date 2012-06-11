plan(2);
test("Check that debug screen!", function() {
    expect(2);
    var e = document.getElementById('appname');
    equal(e.innerHTML, "t::TestApp");
    equal(e.innerHTML, "t::TestApp", "with a name");
});
