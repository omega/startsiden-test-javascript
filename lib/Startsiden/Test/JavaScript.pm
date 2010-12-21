package Startsiden::Test::JavaScript;
use strict;
use warnings;
use base qw(Test::Builder::Module);

my $CLASS = __PACKAGE__;

use Sub::Exporter -setup => {
    exports => [
        qw(js_test js_live_test),
    ],
    groups => {
        default => [qw/js_test js_live_test/],
    },
};

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

    if ($type eq 'cat') {

        Class::Load::load_class($app);
        $app->setup_engine('PSGI');
        my $psgi = sub { $app->run(@_) };

        _run_psgi($psgi, $url);

    } elsif ($type eq 'psgi') {
        # We try to load the psgi and use that
        require Plack::Util;

        my $psgi = Plack::Util::load_psgi($app);

        _run_psgi($psgi, $url);
    } elsif (!$app and !$url) {
        _run_rhino(find_test_lib(), $type); # Only one arg, must be url!
    } else {
        die "We do not support type $type together with app $app and url $url yet :/";
    }
}
sub js_test {
    my ($content) = @_;
    my @argv;

    push(@argv, find_test_lib());

    if ($content) {
        # Need to write out the content to a temp-file
        my ($fh, $file) = tempfile();
        print $fh $content;
        close $fh;
        # now to pass that to the JS test
        push(@argv, $file);
    }
    _run_rhino(@argv);
}

sub _run_psgi {
    my ($psgi, $url) = @_;
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

        push(@argv, find_test_lib(), shift->(GET $url)->base);
        _run_rhino(@argv);
    };
}
sub _run_rhino {
    my $cmd = ($ENV{RHINO_DEBUG} ? 'rhinod' : 'rhino');
    $cmd = "$cmd $0.js " . join(" ", @_);
    my $TAP = Capture::Tiny::tee_merged { system($cmd) };
    $TAP ||= '';
    if($?) {
        # Error executing tests
        warn "Could not execute rhino tests from $0.js: $? $! $TAP";
        exit $?;
    }
}
sub find_test_lib {
    # XXX: Need to support devel checkouts as well

    my $f = 'startsiden-test.js';
    my $dir;
    try {
        $dir = dir(dist_dir('Startsiden-Test-JavaScript'));
    };
    unless ($dir and -f $dir->file($f)) {
        # XXX: Argh, I hate this.
        my $pkg = __PACKAGE__ . ".pm";

        $pkg =~ s|::|/|g;
        my $file = file($INC{$pkg});
        $dir = $file->dir;
        while ($dir->parent ne $dir) {
            if (-d $dir->subdir('share')) {
                $dir = $dir->subdir('share');
                last;
            }
            $dir = $dir->parent;
        }
    }
    unless (-f $dir->file($f)) {
        croak("Could not locate $f");
    }
    return $dir->file($f);
}
1;
