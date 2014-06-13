package Startsiden::Test::JavaScript::Karma;
use Moose;
extends 'Startsiden::Test::JavaScript::Base';

use File::Share ':all';

sub _generate_command {
    my ( $self, $args ) = @_;
    my $installTools =
        $args->{installTools}
        ? 'npm install -g bower; npm install -g karma-cli; '
        : '';
    my $resolveBower = $args->{resolveBower} ? 'bower install;' : '';
    my $resolveNpm   = $args->{resolveNpm}   ? 'npm install;'   : '';
    my $resolveKarmaTapReporter =
        $args->{resolveKarmaTapReporter}
        ? 'npm install '
        . dist_dir('Startsiden-Test-JavaScript')
        . '/karma-tab-reporter;'
        : '';
    my $karmaConfPath = $args->{karmaConfPath} || '';
    my $karma = "karma start $karmaConfPath --single-run --reporters tap";
    my $cmd =
        "$installTools $resolveBower $resolveNpm $resolveKarmaTapReporter $karma";
    print $cmd . "\n";
    return $cmd;
}
