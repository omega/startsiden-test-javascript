#!/usr/bin/env perl

use strict;
use warnings;

use Startsiden::Test::JavaScript;

my $args = {
    gruntTask => 'test'
};

js_grunt_test $args;
