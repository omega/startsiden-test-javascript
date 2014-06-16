package Startsiden::Test::JavaScript;
use strict;
use warnings;
use base qw(Test::Builder::Module);
our $VERSION = '0.006';
my $CLASS = __PACKAGE__;

use Sub::Exporter -setup => {
    exports => [
        qw(js_test js_live_test js_karma_test js_grunt_test),
    ],
    groups => {
        default => [qw/js_test js_live_test js_karma_test js_grunt_test/],
    },
};

use Startsiden::Test::JavaScript::PhantomJs;
use Startsiden::Test::JavaScript::Karma;
use Startsiden::Test::JavaScript::Grunt;
use File::Temp qw(tempfile);

use Class::Load qw();

sub js_live_test {
    my ($type, $app, $url) = @_;
    my $runner = Startsiden::Test::JavaScript::PhantomJs->new();

    if ($type eq 'cat') {

        Class::Load::load_class($app);
        my $psgi;
        if  ($app->can('psgi_app')) {
            $psgi = $app->psgi_app;
        } else {
            $app->setup_engine('PSGI');
            $psgi = sub { $app->run(@_) };
        }

        $runner->_run_psgi($psgi, $url);

    } elsif ($type eq 'psgi') {
        # We try to load the psgi and use that
        require Plack::Util;

        my $psgi = Plack::Util::load_psgi($app);

        $runner->_run_psgi($psgi, $url);
    } elsif (!$app and !$url) {
        _run_os_command($runner->find_test_lib(), $type); # Only one arg, must be url!
    } else {
        die "We do not support type $type together with app $app and url $url yet :/";
    }
}
sub js_test {
    my ($content) = @_;
    my $runner = Startsiden::Test::JavaScript::PhantomJs->new();
    my @argv;

    push(@argv, $runner->find_test_lib());
    my $f;
    if ($content and $content !~ /\n/ and -f $content) {
        # Content is a file :p
        push(@argv, $content);
    } elsif ($content) {
        # Need to write out the content to a temp-file
        my ($fh, $file) = tempfile( DIR => 't/', SUFFIX => '.html' );
        print $fh $content;
        close $fh;
        # now to pass that to the JS test
        push(@argv, $file);
        $f = $file;
    }
    $runner->_run_os_command(@argv);
    unlink($f) if $f;
}

sub js_karma_test {
    my ($args) = @_;
    my $runner = Startsiden::Test::JavaScript::Karma->new();
    $runner->_run_os_command($args);
}

sub js_grunt_test {
    my ($args) = @_;
    my $runner = Startsiden::Test::JavaScript::Grunt->new();
    $runner->_run_os_command($args);
}

1;
