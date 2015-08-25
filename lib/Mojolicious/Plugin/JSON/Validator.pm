package Mojolicious::Plugin::JSON::Validator;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader;
use JSON::Validator;

our $VERSION = '0.01';

sub register {
	my ($self, $app) = @_;

	$app->hook(around_action => sub {
		my ($next, $c, $action, $last) = @_;

		my $route = $c->match->endpoint;
		my $schema;
		if($route->to->{"json_validator.schema"}) {
			$schema = $route->to->{"json_validator.schema"};
		} else {
			$schema = $app->home->rel_file(sprintf "%s.schema.json", $route->name);
		}

		if(ref $schema or $schema =~ m{^\w+://} or -f $schema) {
			my $validator = JSON::Validator->new->schema($schema);
			if(my @errors = $validator->validate($c->req->json)) {
				return $c->render(status_code => 400, json => {errors => [@errors]});
			}
		}
		$next->()
	});
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::JSON::Validator - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('JSON::Validator');

  $r->post("/bla")->to("cont#act1", "json_validator.schema" => "file.schema.json");
  $r->post("/ble")->to("cont#act2", "json_validator.schema" => "file.schema.yaml");
  $r->post("/bli")->to("cont#act3", "json_validator.schema" => {type => 'string', minLength => 3, maxLength => 10});

  # Mojolicious::Lite
  use Mojolicious::Lite;
  plugin "JSON::Validator";

  post "/" => sub{shift->render(text => "OK\n")} => "bla";

  app->start

=head1 DESCRIPTION

L<Mojolicious::Plugin::JSON::Validator> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::JSON::Validator> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
