package Startsiden::Test::JavaScript::Base;
use Moose;
use File::ShareDir qw(dist_dir);
use Try::Tiny;
use File::Temp qw(tempfile);
use Path::Class;
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
