# Makefile.PL for a package defined by PP code.

use PDL::Core::Dev;            # Pick up development utilities
use ExtUtils::MakeMaker;

$netcdf_lib_path     = '/usr/local/lib';
$netcdf_include_path = '/usr/local/include';

$package = ["netcdf.pd",NetCDF,PDL::NetCDF];
WriteMakefile(
	      'NAME'  	     => 'PDL::NetCDF',
#	      'CCFLAGS'      => '-Dbool=int -g3',  # Necessary on my Linux box, see PROBLEMS file.
	      'CCFLAGS'      => '-g3',
	      'VERSION_FROM' => 'netcdf.pd',
	      'TYPEMAPS'     => [&PDL_TYPEMAP()], 
	      'OBJECT'       => 'NetCDF.o ',
	      'PM'           => { 'NetCDF.pm' => '$(INST_LIBDIR)/NetCDF.pm'},
	      'INC'          => &PDL_INCLUDE()." -I$netcdf_include_path", 
	      'LIBS'         => ["-lnetcdf -L$netcdf_lib_path"],  
	      'clean'        => {'FILES'  => 
				   'NetCDF.pm NetCDF.xs NetCDF.o NetCDF.c'},
	      'dist'         => { COMPRESS => 'gzip', SUFFIX => 'gz' },	
	      );

sub MY::postamble { pdlpp_postamble($package); }	





