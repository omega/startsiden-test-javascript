package Startsiden::Test::JavaScript::PhantomJs;
use Moose;
extends 'Startsiden::Test::JavaScript::Base';

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
