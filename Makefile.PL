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
$ncversion{'nc_inq_var_deflate'} = check_lib(
  header => 'netcdf.h', lib => 'netcdf',
  function => 'nc_inq_var_deflate(0, 0, NULL, NULL, NULL);',
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
