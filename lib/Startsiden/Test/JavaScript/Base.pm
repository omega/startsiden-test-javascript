package Startsiden::Test::JavaScript::Base;
use Moose;
use File::ShareDir qw(dist_dir);
use Path::Class;
use Try::Tiny;
use Capture::Tiny;

use Plack::Test;
use Plack::Builder qw();

use HTTP::Request::Common;

sub _run_psgi {
    my ($self, $psgi, $url) = @_;
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

        # we reset path to $url in case $url redirects
        my $base = shift->(GET $url)->base;
        $base->path_query($url);
        push(@argv, $self->find_test_lib(), $base);
        $self->_run_os_command(@argv);
    };
}

sub find_test_lib {
    my ($self) = @_;
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

sub _run_os_command {
    my ($self, @args) = @_;
    my $cmd = $self->_generate_command(@args);
    #warn "CMD: $cmd";
    my $TAP = Capture::Tiny::tee_merged { system($cmd) };
    $TAP ||= '';
    if($?) {
        # Error executing tests
        exit $?;
    }
}

1;
