use t::TestApp;
use Plack::Builder;

builder { 
	t::TestApp->psgi_app( @_ ); 
};
