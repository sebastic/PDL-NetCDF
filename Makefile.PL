# Makefile.PL for a package defined by PP code.

use PDL::Core::Dev;            # Pick up development utilities
use ExtUtils::MakeMaker;
use Config;

# 
## Search for netcdf library and include file
#

foreach my $libdir (
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
Please add the correct library path to Makefile.PL or install NetCDF" 
  unless defined ($netcdf_lib_path);

foreach my $incdir (
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
Please add the correct library path to Makefile.PL or install NetCDF" 
  unless defined ($netcdf_include_path);

# Check if compiled under gcc/Linux.  In which case, define bool for the compiler
$define_bool = '';
if ($Config{'osname'} =~ linux) {
  $define_bool = '-Dbool=int';
  print "Defining bool=int (linux seems to need this)\n";
}

# Included to allow CPAN to detect inheritance from PDL
# and include in PDL modules directory.            
rename 'NetCDF.pm', 'NetCDF.pm.old' if -f 'NetCDF.pm';

$package = ["netcdf.pd",NetCDF,PDL::NetCDF];
WriteMakefile(
	      'NAME'  	     => 'PDL::NetCDF',
	      'CCFLAGS'      => "$define_bool -g",  
	      'VERSION_FROM' => 'netcdf.pd',
	      'TYPEMAPS'     => [&PDL_TYPEMAP()], 
	      'OBJECT'       => 'NetCDF.o ',
	      'PM'           => { 'NetCDF.pm' => '$(INST_LIBDIR)/NetCDF.pm'},
	      'INC'          => &PDL_INCLUDE()." -I$netcdf_include_path", 
	      'LIBS'         => ["-L$netcdf_lib_path -lnetcdf "],  
	      'clean'        => {'FILES'  => 
				   'NetCDF.pm NetCDF.xs NetCDF.o NetCDF.c'},
	      'dist'         => { COMPRESS => 'gzip', SUFFIX => 'gz' },	
	      );

sub MY::postamble { pdlpp_postamble($package); }	





