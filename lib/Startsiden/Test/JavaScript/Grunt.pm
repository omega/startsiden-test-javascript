package Startsiden::Test::JavaScript::Grunt;
use Moose;
extends 'Startsiden::Test::JavaScript::Base';

use File::Share ':all';
use JSON qw( decode_json );

sub _generate_command {
    my ( $self, $args ) = @_;
    my $tools = '';
    $tools .= 'npm install -g --silent bower;'     unless `which bower`;
    $tools .= 'npm install -g --silent karma-cli;' unless `which karma`;
    $tools .= 'npm install -g --silent grunt-cli;' unless `which grunt`;
    my $bower_dir = 'public/bower_components';
    if ( -e '.bowerrc' ) {
        my $json;
        {
            local $/;
            open my $fh, "<", ".bowerrc";
            $json = <$fh>;
            close $fh;
        }
        my $data = decode_json($json);
        $bower_dir = $data->{directory} if $data->{directory};
    }
    my $bower =
        -e 'bower.json' && !-d $bower_dir ? 'bower install --silent;' : '';
    my $npm_dir = 'node_modules';
    my $npm = -e 'package.json' && !-d $npm_dir ? 'npm install --silent;' : '';
    my $reporter_dir = 'karma-tab-reporter';
    my $reporter =
        !-d $npm_dir . '/' . $reporter_dir
        ? 'npm install --silent '
        . dist_dir('Startsiden-Test-JavaScript') . '/'
        . $reporter_dir . ';'
        : '';
    my $grunt_task = $args->{gruntTask} || 'karma';
    my $grunt      = "grunt $grunt_task;";
    my $cmd        = "$tools $bower $npm $reporter $grunt";
    return $cmd;
}
