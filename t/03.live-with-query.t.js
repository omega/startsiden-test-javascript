plan(1);

test("check that we can use jQuery from another JS file", 2, function() {
    equal($('#url').html(), '/query',
         "the url request send correctly");
    equal($('#query').html(), '?q=hola',
         "the query string in url send correctly");
});