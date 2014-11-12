use Startsiden::Test::JavaScript;
use t::TestApp;

js_live_test psgi => t::TestApp->path_to('app.psgi') => '/ajax';