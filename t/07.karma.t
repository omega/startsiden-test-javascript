#!/usr/bin/env perl

use strict;
use warnings;

use Startsiden::Test::JavaScript;

my $args = {
    # Optional Karma configuration path if it is not Karma.conf.js
    karmaConfPath => 't/07.karma.t.conf.js',
    # If true, it will install Node.js bower and karma-cli packages before running Karma test.
    installTools            => 1,
    # If true, it will resolve Bower dependencies before running Karma test.
    resolveBower            => 1,
    # If true, it will resolve NPM dependencies before running Karma test.
    resolveNpm              => 1,
    # If true, it will resolve the karma-tab-reporter NPM package from the share/karma-tab-reporter folder before running Karma test.
    resolveKarmaTapReporter => 1
};

js_karma_test $args;
