package WebApp;
use strict; use warnings;

use base qw/CGI::Prototype::Moose/ ;

sub template { \ <<'END_OF_TEMPLATE' }

<HTML>
<B>Hello world</b> at [% USE Date; Date.format(date.now) | html %]!
</html>
END_OF_TEMPLATE

1;
