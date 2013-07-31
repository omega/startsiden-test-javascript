package Startsiden::Test::JavaScript::WebSpecter;
use Moose;
extends 'Startsiden::Test::JavaScript::Base';

sub _generate_command {
    "webspecter $0.js";
}

1;
