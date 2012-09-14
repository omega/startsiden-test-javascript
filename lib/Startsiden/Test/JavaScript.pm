package Startsiden::Test::JavaScript;
use strict;
use warnings;
use base qw(Test::Builder::Module);
our $VERSION = '0.006';
my $CLASS = __PACKAGE__;

use Sub::Exporter -setup => {
    exports => [
        qw(js_test js_live_test),
    ],
    groups => {
        default => [qw/js_test js_live_test/],
    },
};

use Startsiden::Test::JavaScript::Base;
use File::ShareDir qw(dist_dir);
use File::Temp qw(tempfile);
use Path::Class;
use Try::Tiny;

use Plack::Test;
use Plack::Builder qw();

use HTTP::Request::Common;
use Class::Load qw();

use Capture::Tiny;

sub js_live_test {
    my ($type, $app, $url) = @_;
    my $runner = Startsiden::Test::JavaScript::Base->new();

    if ($type eq 'cat') {

        Class::Load::load_class($app);
        my $psgi;
        if  ($app->can('psgi_app')) {
            $psgi = $app->psgi_app;
        } else {
            $app->setup_engine('PSGI');
            $psgi = sub { $app->run(@_) };
        }

        _run_psgi($psgi, $url);

    } elsif ($type eq 'psgi') {
        # We try to load the psgi and use that
        require Plack::Util;

        my $psgi = Plack::Util::load_psgi($app);

        _run_psgi($psgi, $url);
    } elsif (!$app and !$url) {
        _run_os_command($runner->find_test_lib(), $type); # Only one arg, must be url!
    } else {
        die "We do not support type $type together with app $app and url $url yet :/";
    }
}
sub js_test {
    my ($content) = @_;
    my $runner = Startsiden::Test::JavaScript::Base->new();
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
    _run_os_command(@argv);
    unlink($f) if $f;
}

sub _run_psgi {
    my ($psgi, $url) = @_;
    my $runner = Startsiden::Test::JavaScript::Base->new();
    $Plack::Test::Impl = 'Server' unless $ENV{PLACK_TEST_IMPL};
    $ENV{PLACK_SERVER} ||= 'HTTP::Server::Simple';
    my $app = Plack::Builder::builder {
        if ($ENV{TEST_VERBOSE}) {
            # XXX: Fix the format to be a bit nicer.. too much info now.
            # Remember to start with #, since we output TAP
            Plack::Builder::enable 'Plack::Middleware::AccessLog';
        }
        $psgi;
    };
    test_psgi $app, sub {
        my @argv;

        push(@argv, $runner->find_test_lib(), shift->(GET $url)->base);
        _run_os_command(@argv);
    };
}
sub _run_os_command {
    my $cmd = _generate_command(@_);
    #warn "CMD: $cmd";
    my $TAP = Capture::Tiny::tee_merged { system($cmd) };
    $TAP ||= '';
    if($?) {
        # Error executing tests
        exit $?;
    }
}
sub _generate_command {
    my ($test, @args) = @_;
    my $cmd = 'phantomjs';
    # XXX: Should send in location for qunit etc probably
    my $inc = join(":", ($ENV{JSINC} ? $ENV{JSINC} : () ),
        '/usr/local/share/startsiden-javascript-qunit'
    );
    $cmd = join(" ", $cmd, $test, "$0.js", @args, "INC:$inc");
    return $cmd;
}

1;
