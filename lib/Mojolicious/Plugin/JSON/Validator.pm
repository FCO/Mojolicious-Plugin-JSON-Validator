package Mojolicious::Plugin::JSON::Validator;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader;
use JSON::Validator;

our $VERSION = '0.01';

sub register {
	my ($self, $app, $config) = @_;
	my $format	= $config->{format}		|| 'json';
	my $validator	= $config->{validator}		|| JSON::Validator->new;
	my $autovalid	= $config->{auto_validate};

	$app->helper(
		validate_json => sub {
			my $c      = shift;
			my $data   = shift || $c->req->json;
			my $schema = shift || $c->stash('json.validator.schema');

			unless ($schema) {
				my $controller	= $c->stash->{controller};
				my $action	= $c->stash->{action};
				$schema = ($controller and $action) ? join '/', split('-', decamelize $controller), $action : 'default';
				$schema .= ".spec.$format";
			}

			return $validator->schema($schema)->validate($data);
		}
	);
	$app->hook(around_action => sub {
		my ($next, $c, $action, $last) = @_;
		if(not $c->stash->{'json.validator.schema'}) {
			return $next->();
		}
		my @errors = $c->validate_json;
		if($autovalid eq "render") {
			if(@errors) {
				$c->res->code($c->stash->{'json.validator.code'} || 400);
				if(my $template = $c->stash->{'json.validator.template_error'}) {
					$c->render($template)
				} elsif(my $inline = $c->stash->{'json.validator.inline_error'}) {
					$c->render(inline => $inline)
				} else {
					$c->render(json => {errors => [@errors]});
					#$c->respond_to(
					#	json	=> {json => {errors => [@errors]}},
					#	#xml	=> {inline => "<errors><% for my $err(@$errors) { %> <error><%= $err %></error> <% } %></errors>", errors => [@errors]},
					#	#html	=> {inline => "<ul><% for my $err(@$errors) { %> <li><%= $err %></li> <% } %></ul>", errors => [@errors]},
					#)
				}
			} else {
				$next->();
			}
		} else {
			$c->$action(@errors)
		}
	}) if $autovalid;
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::JSON::Validator - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('JSON::Validator', auto_validate => render);

  $r->post("/bla")->to("cont#act1", "json.validator.schema" => "file.schema.json");
  $r->post("/ble")->to("cont#act2", "json.validator.schema" => "file.schema.yaml");
  $r->post("/bli")->to("cont#act3", "json.validator.schema" => {type => 'string', minLength => 3, maxLength => 10});

  # Mojolicious::Lite
  use Mojolicious::Lite;
  plugin JSON::Validator => auto_validate => "render";

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
