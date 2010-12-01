use inc::Module::Install;
name 'Startsiden-Test-JavaScript';
all_from 'lib/Startsiden/Test/JavaScript.pm';

requires 'Sub::Exporter';
requires 'File::ShareDir';
requires 'File::Temp';
requires 'Path::Class';
requires 'Try::Tiny';

install_share;

