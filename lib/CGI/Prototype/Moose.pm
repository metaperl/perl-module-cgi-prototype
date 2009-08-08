package CGI::Prototype::Moose;

use 5.006;
use strict;
use warnings;

use Moose;

has 'CGI'    => (is => 'rw', lazy_build => 1);
has 'engine' => (is => 'rw', lazy_build => 1);
has 'engine_config' => (is => 'rw', default => sub { {} }) ;

has 'template' => (is => 'rw', lazy_build => 1);

$ENV{Debug} = 1;
use CGI::Carp::DebugScreen ( debug => 1 );


sub _build_CGI {
    my($self)=@_;

    use CGI::Simple;
    CGI::Simple->new;
}

sub _build_engine {
    my($self)=@_;

    require Template;
    Template->new($self->engine_config)
      or die "Creating tt: $Template::ERROR\n";

}

sub _build_template {
  \ '[% self.CGI.header %]This page intentionally left blank.';
}


sub activate {
  my $self = shift;
  eval {
    $self->prototype_enter;
    $self->app_enter;
    my $this_page = $self->dispatch;
    $this_page->control_enter;
    $this_page->respond_enter;
    my $next_page = $this_page->respond;
    $this_page->respond_leave;
    if ($this_page ne $next_page) {
      $this_page->control_leave;
      $next_page->control_enter;
    }
    $next_page->render_enter;
    $next_page->render;
    $next_page->render_leave;
    $next_page->control_leave;
    $self->app_leave;
    $self->prototype_leave;
  };
  $self->error($@) if $@;	# failed something, go to safe mode
}

sub display {			# override this to grab output for testing
  my $self = shift;
  my $output = shift;
  print $output;
}


sub render {
  my $self = shift;
  my $tt = $self->engine;

  $tt->process($self->template, { self => $self }, \my $output)
    or die $tt->error;	# passes Template::Exception upward
  $self->display($output);
}


sub param {
  shift->cgi->param(@_);	# convenience method
}


sub prototype_enter { }

sub prototype_leave { }

sub app_enter {}

sub app_leave {}

sub control_enter {}

sub control_leave {}

sub render_enter {}

sub render_leave {}

sub respond_enter {}

sub respond_leave {}

sub error {
  my $self = shift;
  my $error = shift;
  $self->display("Content-type: text/plain\n\nERROR: $error");
}

sub dispatch {
  my $self = shift;
  return $self;		# do nothing, stay here
}

sub respond {
  my $self = shift;
  return $self;		# do nothing, stay here
}

=back

=head1 SEE ALSO

L<Moose>

=head1 SUPPORT, MAILING LIST, SOURCE REPO

The mailing list for CGI::Prototype is archived at
L<http://www.mail-archive.com/cgi-prototype-users@lists.sourceforge.net/index.html>

You may sign up here
L<https://lists.sourceforge.net/lists/listinfo/cgi-prototype-users>

for general discussion or bug reports.

=head2 Source repo

Randal Schwartz maintains the source repo on github:
http://github.com/RandalSchwartz/perl-module-cgi-prototype/tree/master

Terrence Brannon has the moose-active fork of the repo at:
L<http://github.com/metaperl/perl-module-cgi-prototype/tree/master>


=head1 AUTHOR

Terrence Brannon

=head1 COPYRIGHT AND LICENSE


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
