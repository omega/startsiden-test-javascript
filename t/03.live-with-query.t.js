plan(1);

test("check that we can send request with query string", 2, function() {
    equal($('#url').html(), '/query',
         "the url request send correctly");
    equal($('#query').html(), '?q=hola',
         "the query string in url send correctly");
});