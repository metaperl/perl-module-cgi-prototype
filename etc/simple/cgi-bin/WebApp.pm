package WebApp;

use base CGI::Prototype::Moose;


sub template { \ <<'END_OF_TEMPLATE' }
[% self.CGI.header; %]
Hello world at [% USE Date; Date.format(date.now) | html %]!
END_OF_TEMPLATE

1;
