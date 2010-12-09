use Startsiden::Test::JavaScript;

use Test::More;
use Test::WWW::Mechanize::Catalyst;

use Plack::Test;
use HTTP::Request::Common;
$Plack::Test::Impl = 'Server' unless $ENV{PLACK_TEST_IMPL};
$ENV{PLACK_SERVER} ||= 'HTTP::Server::Simple';

use t::TestApp;
t::TestApp->setup_engine('PSGI');
my $app = sub { t::TestApp->run(@_) };

test_psgi $app, sub {
    js_test_live shift->(GET "/ajax")->base;
};
