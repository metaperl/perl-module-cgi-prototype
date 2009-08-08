package CGI::Prototype::Moose;

use Moose;

has 'request'  => (is => 'ro', lazy_build => 1);
has 'response' => (is => 'ro', lazy_build => 1);
has 'log'      => (is => 'rw', lazy_build => 1);

has 'output'   => (is => 'rw');
has 'CGI'    => (is => 'rw', lazy_build => 1);
has 'engine' => (is => 'rw', lazy_build => 1);
has 'engine_config' => (is => 'rw', lazy_build => 1);

has 'template' => (is => 'rw', lazy_build => 1);

has 'session_start_time' => (is => 'rw');



sub _build_request {
    require Mojo::Message::Request;
    Mojo::Message::Request->new
}

sub _build_response {
    require Mojo::Message::Response;

    my $response = Mojo::Message::Response->new;

    $response->code(200);
    $response->headers->content_type('text/html');

    $response;
}

sub _build_log {
    require Mojo::Log;

    my $log = Mojo::Log->new;
    $log;
}

sub _build_CGI {
    my($self)=@_;

    require CGI::Simple;
    CGI::Simple->new;
}

sub _build_engine {
    my($self)=@_;

    require Template;
    Template->new($self->engine_config)
      or die "Creating tt: $Template::ERROR\n";

}

sub _build_engine_config { {} }

sub _build_template {
   'This page intentionally left blank.';
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

# sub display {			# override this to grab output for testing
#   my $self = shift;
#   my $output = shift;
#   print $output;
# }

sub redirect {
    my($self, $url)=@_;

    $self->response->code(302)->headers->location($url);
}

sub render {
  my $self = shift;
  my $tt = $self->engine;

  $tt->process($self->template, { self => $self }, \my $output)
    or die $tt->error;	
  $self->output($output);
}


sub param {
  shift->cgi->param(@_);	# convenience method
}


sub prototype_enter {
    my($self)=@_;

    require Time::HiRes;
    $self->session_start_time ( [Time::HiRes::gettimeofday()] ) ;
}

sub prototype_leave { 
    my($self)=@_;

    my $elapsed = sprintf '%f',
      Time::HiRes::tv_interval($self->session_start_time, [Time::HiRes::gettimeofday()]);
    my $rps = $elapsed == 0 ? '??' : sprintf '%.3f', 1 / $elapsed;
    $self->log->debug("=== Request took $elapsed seconds ($rps/s) ===");

}

sub app_enter {}

sub app_leave {
    my($self)=@_;

    $self->response->body($self->output);

    my $message = '';

    # Headers
    $message .= $self->response->build_headers;

    # Body
    $message .= $self->response->build_body;

    print $message;

}

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


1;
