package WebApp;
use strict; use warnings;

use base qw/CGI::Prototype::Moose/ ;



use Carp;
$SIG{__DIE__} = \*Carp::confess;




sub template { die "hi there" }

sub tmplate { \ <<'END_OF_TEMPLATE' }

<HTML>
<B>Hello world!</b> at [% USE Date; Date.format(date.now) | html %]
</html>
END_OF_TEMPLATE

1;
