use inc::Module::Install;
name 'Startsiden-Test-JavaScript';
all_from 'lib/Startsiden/Test/JavaScript.pm';

requires 'Sub::Exporter';
requires 'File::ShareDir';
requires 'File::Temp';
requires 'Path::Class';
requires 'Try::Tiny';
requires 'Plack';
requires 'HTTP::Request::Common';
requires 'Capture::Tiny';
requires 'Class::Load';

test_requires 'Test::WWW::Mechanize::Catalyst';
test_requires 'Catalyst::Plugin::Static::Simple';
test_requires 'Catalyst::Plugin::ConfigLoader';
test_requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Engine::PSGI';

install_share;

dpkg_requires 'startsiden-javascript-qunit';

WriteAll;
