use ExtUtils::MakeMaker;
use PDL::Core::Dev;

#----------------------------------------------------------------
# THESE MUST BE CHANGED TO CORRECT VALUES FOR YOUR SYSTEM
$netcdf_lib_path     = '/opt/local/lib';
$netcdf_include_path = '/opt/local/include';
#----------------------------------------------------------------

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'PDL::NetCDF',
    'VERSION_FROM' => 'NetCDF.pm', # finds $VERSION
    'TYPEMAPS'     => [PDL_TYPEMAP], 
    'LIBS'	=> ["-L$netcdf_lib_path -lnetcdf"],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> PDL_INCLUDE." -I$netcdf_include_path",     # e.g., '-I/usr/include/other' 
    'dist'      => { COMPRESS => 'gzip', SUFFIX => 'gz' },
);

sub MY::postamble { PDL::Core::Dev::postamble() } # Add genpp rule
