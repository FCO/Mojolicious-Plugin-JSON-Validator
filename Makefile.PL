use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::JSON::Validator',
  VERSION_FROM => 'lib/Mojolicious/Plugin/JSON/Validator.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '6.05', 'JSON::Validator' => '0.51'},
  test         => {TESTS => 't/*.t'}
);
