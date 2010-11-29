#!/usr/bin/env perl
#
#
# Need to start some sort of web-app

sub js_test {
    my ($content) = @_;

    # Need to write out the content to a temp-file

    use File::Temp qw(tempfile);

    my ($fh, $file) = tempfile();
    print $fh $content;

    close $fh;

    # now to pass that to the JS test
    if(system('rhino', $0 . '.js', $file)) {
        # Error executing tests
        warn "Could not execute rhino tests from $file: $?";
        exit $?;
    }
}

# Then we need to make some requests

#my $c = get('/search');
my $c = '<html><body><div id="search" class="hidden"></div></body></html>';
# run som javascript on the result

js_test $c;

