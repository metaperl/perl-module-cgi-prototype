#!/usr/bin/perl -I/home/tbrannon/prg/perl-module-cgi-prototype/lib

BEGIN 
{
    use Data::Dumper;
    warn Dumper \@INC;
}	

use WebApp;

WebApp->new->activate;
