#!/usr/bin/env perl
#

use strict;
use warnings;
use Startsiden::Test::JavaScript;

$ENV{PATH}='t/bin/:' . $ENV{PATH};

js_test;



