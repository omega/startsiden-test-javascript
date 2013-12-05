use inc::Module::Install;

name 'Startsiden-Test-JavaScript';

all_from 'lib/Startsiden/Test/JavaScript.pm';

requires 'Capture::Tiny';
requires 'Catalyst::Engine::PSGI';
requires 'Class::Load';
requires 'File::ShareDir';
requires 'File::Temp';
requires 'HTTP::Request::Common';
requires 'Path::Class';
requires 'Plack';
requires 'Sub::Exporter';
requires 'Try::Tiny';

test_requires 'Catalyst::Action::RenderView';
test_requires 'Catalyst::Plugin::ConfigLoader';
test_requires 'Catalyst::Plugin::Static::Simple';
test_requires 'Test::WWW::Mechanize::Catalyst';

install_share;

dpkg_requires 'startsiden-javascript-qunit';

WriteAll;
