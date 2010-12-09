use t::TestApp;
t::TestApp->setup_engine('PSGI');
my $app = sub { t::TestApp->run(@_) };

