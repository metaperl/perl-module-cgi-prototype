#! perl
use Test::More no_plan;

use strict;
use warnings;

require_ok 'CGI::Prototype::Moose';

my @callbacks = qw(prototype_enter prototype_leave
		   app_enter app_leave
		   control_enter control_leave
		   render_enter render_leave
		   respond_enter respond_leave);

my @TRACE;

sub show_trace {
    use Data::Dumper;
    diag Dumper("TRACE", \@TRACE);
    diag join "\n", map "[".join(",",@$_)."]", @TRACE;
}


my $RESPOND = "My::App::One";
{
  package My::App;
  use Moose;
  our @ISA = qw(CGI::Prototype::Moose);

  sub TRACE {
      my $self = shift;
      my $pkg = ref $self || $self;
      push @TRACE, [$pkg, shift, @_];
  }

  sub dispatch {
    shift->TRACE("dispatch", @_);
    return 'My::App::One';
  }

  sub template {
      my $self=shift;
      ref $self . ' template';
  }

#   for my $m ("display", @callbacks) {
#     *{__PACKAGE__ . "::$m"} = sub {
#       shift->TRACE($m, @_);
#     }

  for my $method ("display", @callbacks) {
      override $method => sub { shift->TRACE($method, @_); } ;
  }

}

{
  package My::App::One;
  our @ISA = qw(My::App);

  sub respond {
    shift->TRACE("respond", @_);
    return $RESPOND;
  }
}

{
  package My::App::Two;
  our @ISA = qw(My::App);

}

@TRACE =();
My::App->activate;
show_trace;
is_deeply \@TRACE,
  [
   ['My::App', 'prototype_enter'],
   ['My::App', 'app_enter'],
   ['My::App', 'dispatch'],
   ['My::App::One', 'control_enter'],
   ['My::App::One', 'respond_enter'],
   ['My::App::One', 'respond'],
   ['My::App::One', 'respond_leave'],
   ['My::App::One', 'render_enter'],
   ['My::App::One', 'display', 'My::App::One template'],
   ['My::App::One', 'render_leave'],
   ['My::App::One', 'control_leave'],
   ['My::App', 'app_leave'],
   ['My::App', 'prototype_leave'],
  ],
  'correct steps called for same page';

@TRACE = ();
$RESPOND = "My::App::Two";
My::App->activate;
is_deeply \@TRACE,
  [
   ['My::App', 'prototype_enter'],
   ['My::App', 'app_enter'],
   ['My::App', 'dispatch'],
   ['My::App::One', 'control_enter'],
   ['My::App::One', 'respond_enter'],
   ['My::App::One', 'respond'],
   ['My::App::One', 'respond_leave'],
   ['My::App::One', 'control_leave'],
   ['My::App::Two', 'control_enter'],
   ['My::App::Two', 'render_enter'],
   ['My::App::Two', 'display', 'My::App::Two template'],
   ['My::App::Two', 'render_leave'],
   ['My::App::Two', 'control_leave'],
   ['My::App', 'app_leave'],
   ['My::App', 'prototype_leave'],
  ],
  'correct steps called for new page';

