package Startsiden::Test::JavaScript;

use Sub::Exporter -setup => {
    exports => [
        qw(js_test),
    ],
    groups => {
        default => [qw/js_test/],
    },
};

use File::ShareDir qw(dist_dir);
use File::Temp qw(tempfile);
use Path::Class;
use Try::Tiny;

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

    if(system('rhino', $0 . '.js', @argv)) {
        # Error executing tests
        warn "Could not execute rhino tests from $file: $?";
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
