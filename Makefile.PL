use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Clone',
    'VERSION_FROM' => 'Clone.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '-g',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '-g',     # e.g., '-I/usr/include/other' 
);

