use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin "JSON::Validator", auto_validate => "render";

post "/test1" => sub {
  my $c = shift;
  $c->render(text => "Hello Mojo!");
};

post '/test2' => {"json.validator.schema" => {type => "string"}} => sub {
  my $c		= shift;
  $c->render(text => "Hello Mojo!")
};

post '/test3' => {"json.validator.schema" => {type => "string"}, "json.validator.code" => 404} => sub {
  my $c		= shift;
  $c->render(text => "Hello Mojo!")
};

my $t = Test::Mojo->new;
$t->post_ok("/test1")->status_is(200)->content_is("Hello Mojo!");
$t->post_ok("/test2")->status_is(400)->json_is({errors => [{message => "Expected string - got null.", path => "\/"}]});
$t->post_ok("/test3")->status_is(404)->json_is({errors => [{message => "Expected string - got null.", path => "\/"}]});

done_testing();
