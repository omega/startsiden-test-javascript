use Startsiden::Test::JavaScript;

use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $m = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 't::TestApp');

$m->get_ok('/');
js_test $m->content;

done_testing();
