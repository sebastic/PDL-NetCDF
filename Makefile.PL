# Makefile.PL for a package defined by PP code.

use PDL::Core::Dev;            # Pick up development utilities
use ExtUtils::MakeMaker;
use Config;

# 
## Search for netcdf library and include file
#

foreach my $libdir (
		    $ENV{NETCDF_LIBDIR},
		    '/usr/local/netcdf/lib',
		    '/usr/local/lib',
		    '/opt/local/lib',
		    '/usr/lib',
		    '/opt/lib',
		                  # Add new library paths here!!
		    ) {

  if (-e "$libdir/libnetcdf.so") {
    $netcdf_lib_path = $libdir;
    print "Found libnetcdf.so at $libdir/libnetcdf.so\n";
    last;
  }

  if (-e "$libdir/libnetcdf.a") {
    $netcdf_lib_path = $libdir;
    print "Found libnetcdf.a at $libdir/libnetcdf.a\n";
    last;
  }

}

die "Cannot find netcdf library, libnetcdf.so or libnetcdf.a.  
Please set the environment variable NETCDF_LIBDIR to the correct library path or install NetCDF" 
  unless defined ($netcdf_lib_path);

foreach my $incdir (
		    $ENV{NETCDF_INCDIR},
		    '/usr/local/netcdf/include',
		    '/usr/local/include',
		    '/opt/local/include',
		    '/usr/include',
		    '/opt/include',
		                  # Add new header paths here!!
		    ) {

  if (-e "$incdir/netcdf.h") {
    $netcdf_include_path = $incdir;
    print "Found netcdf.h at $incdir/netcdf.h\n";
    last;
  }
}

die "Cannot find netcdf header file, netcdf.h.
Please set the environment variable NETCDF_INCDIR to the correct include path or install NetCDF" 
  unless defined ($netcdf_include_path);

# Check if compiled under gcc/Linux.  In which case, define bool for the compiler
$define_bool = '';
if ($Config{'osname'} =~ linux) {
  $define_bool = '-Dbool=int';
  print "Defining bool=int (linux seems to need this)\n";
}
            

$package = ["netcdf.pd",NetCDF,PDL::NetCDF];
WriteMakefile(
	      'NAME'  	     => 'PDL::NetCDF',
	      'AUTHOR'       => 'Douglas Hunt (dhunt@ucar.edu)',
	      'PREREQ_PM'    => { PDL => 2.2 },
	      'CCFLAGS'      => "$define_bool -g",  
	      'VERSION_FROM' => 'netcdf.pd',
	      'META_MERGE'   =>  {provides => {PDL::NetCDF => {file => 'netcdf.pd', version => 4.07}}},
	      'TYPEMAPS'     => [&PDL_TYPEMAP()], 
	      'OBJECT'       => 'NetCDF.o ',
	      'PM'           => { 'NetCDF.pm' => '$(INST_LIBDIR)/NetCDF.pm'},
	      'INC'          => &PDL_INCLUDE()." -I$netcdf_include_path", 
	      'LIBS'         => ["-L$netcdf_lib_path -lnetcdf $ENV{NETCDF_EXTRALIBS}"],  
	      'clean'        => {'FILES'  => 
				   'NetCDF.pm NetCDF.xs NetCDF.o NetCDF.c'},
	      'dist'         => { COMPRESS => 'gzip', SUFFIX => 'gz' },	
	      );

sub MY::postamble { pdlpp_postamble($package); }	





