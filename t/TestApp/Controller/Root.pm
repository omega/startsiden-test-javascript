package t::TestApp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub another :Path('a') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body( 'another endpoint' );
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub new_content :Path('/new') {
    my ( $self, $c ) = @_;

    $c->response->body('C');
}

sub ajax :Path('/ajax') {
    my ( $self, $c ) = @_;
    $c->serve_static_file('t/root/ajax.html');
}

sub query :Path('/query') {
    my ( $self, $c ) = @_;
    $c->serve_static_file('t/root/query.html');
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
