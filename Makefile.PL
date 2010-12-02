use inc::Module::Install;
name 'Startsiden-Test-JavaScript';
all_from 'lib/Startsiden/Test/JavaScript.pm';

requires 'Sub::Exporter';
requires 'File::ShareDir';
requires 'File::Temp';
requires 'Path::Class';
requires 'Try::Tiny';

test_requires 'Test::WWW::Mechanize::Catalyst';

install_share;

dpkg_requires 'startsiden-javascript-qunit';
dpkg_requires 'startsiden-javascript-envjs';

WriteAll;
