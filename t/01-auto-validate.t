use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin "JSON::Validator", auto_validate => 1;

post "/test1" => sub {
  my $c = shift;
  $c->render(text => "Hello Mojo!");
};

post '/test2' => {"json.validator.schema" => {type => "string"}} => sub {
  my $c		= shift;
  my @errors	= @_;

  return $c->render(status => 400, text => join $/, @errors) if @errors;
  $c->render(text => "Hello Mojo!")
};

my $t = Test::Mojo->new;
$t->post_ok("/test1")->status_is(200)->content_is("Hello Mojo!");
$t->post_ok("/test2")->status_is(400)->content_is("/: Expected string - got null.");

done_testing();
