plan(4);
test("check that we can use jQuery from another JS file", 1, function() {
    equals($('#append').html(), "D", "Yeah, found appended div");
});
test("Check that ajax!", 2, function() {
    var e = document.getElementById('content');
    equals(e.innerHTML, "a", "content is a at the start");

    // Lets try to click a button
    $('#button').click();
    equals(e.innerHTML, 'B', "content get switched to B when we click first button");

});
$('#button2').click();
test("For real, check the ajax!", function() {
    stop();
    expect(1);
    var t = setTimeout(function() {

        equals($('#content').html(), 'C', "and then to C in ajax call");
        start();
    }, 1000);
});
