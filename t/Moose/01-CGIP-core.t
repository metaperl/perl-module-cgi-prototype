#! perl
use Test::More no_plan;

my @core_slots = qw(request response log output CGI activate app_enter app_leave control_enter
	       control_leave dispatch engine error param
	       render render_enter render_leave respond respond_enter
	       respond_leave template);

require_ok 'CGI::Prototype::Moose';
isa_ok my $m = CGI::Prototype::Moose->new, 'CGI::Prototype::Moose';
isa_ok $m, 'CGI::Prototype::Moose';
can_ok $m, @core_slots;

## now make sure the same thing is true for a derived app:

{
  package My::App;
  @ISA = qw(CGI::Prototype::Moose);
}

isa_ok $m = My::App->new, 'CGI::Prototype::Moose';
isa_ok $m, 'My::App';
can_ok $m, @core_slots;


{
  open my $stdout, ">&STDOUT" or die;
  open STDOUT, '>test.out' or die;
  END { unlink 'test.out' }
  My::App->new->activate;
  open STDOUT, ">&=".fileno($stdout) or die;
}

open IN, 'test.out' or die;
like join("", <IN>), qr/This page intentionally left blank/ms,
  'proper output from null app';

is_deeply [$m->CGI->param], [],
  'verify no params';

