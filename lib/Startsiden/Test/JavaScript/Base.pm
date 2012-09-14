package Startsiden::Test::JavaScript::Base;
use Moose;
use File::ShareDir qw(dist_dir);
use Try::Tiny;
use File::Temp qw(tempfile);
use Path::Class;

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

sub _generate_command {
    my ($self, $test, @args) = @_;
    my $cmd = 'phantomjs';
    # XXX: Should send in location for qunit etc probably
    my $inc = join(":", ($ENV{JSINC} ? $ENV{JSINC} : () ),
        '/usr/local/share/startsiden-javascript-qunit'
    );
    $cmd = join(" ", $cmd, $test, "$0.js", @args, "INC:$inc");
    return $cmd;
}

1;
