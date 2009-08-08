#!/usr/bin/perl

use lib qw(/home/tbrannon/prg/perl-module-cgi-prototype/lib /home/tbrannon/prg/perl-module-cgi-prototype/etc/simple);

BEGIN 
{
    use Data::Dumper;
    warn Dumper \@INC;
}	

use WebApp;

WebApp->new->activate;
