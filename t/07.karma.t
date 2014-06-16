#!/usr/bin/env perl

use strict;
use warnings;

use Startsiden::Test::JavaScript;

my $args = {
    # Optional Karma configuration path if it is not Karma.conf.js
    karmaConfPath => 't/07.karma.t.conf.js'
};

js_karma_test $args;
