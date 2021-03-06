use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME              => 'CGI::Prototype',
   VERSION_FROM      => 'lib/CGI/Prototype.pm',
   PREREQ_PM         => 
   {
    'Template' => 0,
    'Class::Prototyped' => 0,
    
    Moose => 0,
    CGI::Simple => 0,
    Mojo => 0,
    Time::HiRes => 0
   },
   ($] >= 5.005 ?
    (
     AUTHOR         => 'Randal L. Schwartz <merlyn@stonehenge.com>') : ()
   ),

   test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t'}

  );

