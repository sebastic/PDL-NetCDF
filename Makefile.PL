use strict;
use warnings;
use PDL::Core::Dev;            # Pick up development utilities
use ExtUtils::MakeMaker;
use Devel::CheckLib qw(check_lib);
use Data::Dumper;

check_lib(
  header => 'netcdf.h', lib => 'netcdf',
) or die "Cannot find netcdf library. Please install NetCDF.";

# Check if compiled under gcc/Linux.  In which case, define bool for the compiler
my $define_bool = '';
if ($^O =~ /linux/) {
  $define_bool = '-Dbool=int';
  print "Defining bool=int (linux seems to need this)\n";
}

my %ncversion = (); # Information on which netcdf functions/features available.
$ncversion{'nc_inq_var_deflate'} = test_func_exists(
  'nc_inq_var_deflate', 'HDF library installed',
  'nc_inq_var_deflate(0, 0, NULL, NULL, NULL);'
);

# Write these options to a file--used by netcdf.pd during the 'make' step
open my $fh, '>', 'OPTIONS!' or die "Cannot write to OPTIONS! file";
print  {$fh} Dumper(\%ncversion);
close   $fh;

my $package = [qw(netcdf.pd NetCDF PDL::NetCDF)];
my %hash = pdlpp_stdargs($package);
my %more_items = (
  AUTHOR       => 'Douglas Hunt (dhunt@ucar.edu)',
  PREREQ_PM => {
    'PDL' => '2.043',
  },
  CONFIGURE_REQUIRES => {
    'Devel::CheckLib' => '1.14',
    'ExtUtils::MakeMaker' => '6.64', # TEST_REQUIRES
    'PDL' => '2.043',
  },
  TEST_REQUIRES => {
    'Test::More' => '0.88', # done_testing
  },
);
%hash = (%hash, %more_items);
$hash{INC} .= " $define_bool" if $define_bool;
$hash{LIBS}[0] .= " -lnetcdf";
WriteMakefile(%hash);

sub MY::postamble { pdlpp_postamble($package); }

sub test_func_exists {

    my ( $func, $comment, $eval, $option ) = @_;

    $option = $func unless defined $option;

    # Test if PLplot has plsmem, for in memory plotting
    eval { compileAndRun ("-lnetcdf", 0, <<"EOC");
#include <netcdf.h>
main () {  $eval }
EOC
       };

    my $have_func;
    if ($@)
    {
	print "\t$func function not found, no $comment available\n";
	$have_func = 0;
    }
    else
    {
	print "\t$func function found, $comment available!\n";
	$have_func = 1;
    }

    return $have_func;
}

sub compileAndRun {
  my $flags = shift;
  my $run   = shift;
  my $code  = shift;
  require File::Spec;
  require Config;
  my $devnull = File::Spec->devnull(); # Portable null device.

  open (OUT, ">temp.c");
  print OUT $code;
  close OUT;
  unlink './temp'; # since we work out whether the compile succeeds by presence of this
  unlink './temp.exe'; # since we work out whether the compile succeeds by presence of this

  my $cc = $Config::Config{cc};
  my $ccflags = $Config::Config{ccflags};
  print "Trying: $cc $ccflags $flags temp.c -o temp\n";

  # The duplication of $flags seems to be necessary, as some systems
  # need $flags before temp.c and some after.  D. Hunt 2/9/2011
  system "$cc $ccflags $flags temp.c $flags -o temp > $devnull 2>&1";
  unlink('./temp.c');
  die "Cannot compile test program: $code" unless (-e 'temp' or -e 'temp.exe');
  return unless ($run);

  my $res = `./temp`;
  unlink ('./temp');
  unlink ('./temp.exe');
  return $res;
}
