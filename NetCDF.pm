package PDL::NetCDF;

use PDL;
use PDL::Core;
use Carp;
use strict;
use vars qw($VERSION @ISA @EXPORT_OK $AUTOLOAD $constname);

require Exporter;
require AutoLoader;
require DynaLoader;

@ISA = qw(Exporter AutoLoader DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(NC_FILL_BYTE
	     NC_FILL_CHAR
	     NC_FILL_DOUBLE
	     NC_FILL_FLOAT
	     NC_FILL_LONG
	     NC_FILL_SHORT
	     NC_MAX_ATTRS
	     NC_MAX_DIMS
	     NC_MAX_NAME
	     NC_MAX_OPEN
	     NC_MAX_VARS
	     NC_MAX_VAR_DIMS
	     NC_ATTRIBUTE
	     NC_BITFIELD
	     NC_BYTE
	     NC_CHAR
	     NC_CLOBBER
	     NC_CREAT
	     NC_DIMENSION
	     NC_DOUBLE
	     NC_EBADDIM
	     NC_EBADID
	     NC_EBADTYPE
	     NC_EEXIST
	     NC_EGLOBAL
	     NC_EINDEFINE
	     NC_EINVAL
	     NC_EINVALCOORDS
	     NC_EMAXATTS
	     NC_EMAXDIMS
	     NC_EMAXNAME
	     NC_EMAXVARS
	     NC_ENAMEINUSE
	     NC_ENFILE
	     NC_ENOTATT
	     NC_ENOTINDEFINE
	     NC_ENOTNC
	     NC_ENOTVAR
	     NC_ENTOOL
	     NC_EPERM
	     NC_ESTS
	     NC_EUNLIMIT
	     NC_EUNLIMPOS
	     NC_EXCL
	     NC_EXDR
	     NC_FATAL
	     NC_FILL
	     NC_FLOAT
	     NC_GLOBAL
	     NC_HDIRTY
	     NC_HSYNC
	     NC_IARRAY
	     NC_INDEF
	     NC_LINK
	     NC_LONG
	     NC_NDIRTY
	     NC_NOCLOBBER
	     NC_NOERR
	     NC_NOFILL
	     NC_NOWRITE
	     NC_NSYNC
	     NC_RDWR
	     NC_SHORT
	     NC_STRING
	     NC_SYSERR
	     NC_UNLIMITED
	     NC_UNSPECIFIED
	     NC_VARIABLE
	     NC_VERBOSE
	     NC_WRITE
	     nccreate
	     ncopen
	     ncredef
	     ncendef
	     ncclose
	     ncinquire
	     ncsync
	     ncabort
	     ncsetfill
	     ncdimdef
	     ncdimid
	     ncdiminq
	     ncdimrename
	     ncvardef
	     ncvarid
	     ncvarinq
	     ncvarput1
	     ncvarget1
	     ncvarget
	     ncvarput
	     ncvargetscalar
	     ncvarrename
	     ncattput
	     ncattinq
	     ncattget
	     ncattcopy
	     ncattname
	     ncattrename
	     ncattdel
	     ncrecput
	     ncrecget
	     ncrecinq
	     nctypelen
	     ncopts
	     ncerr
	     );
$VERSION = '0.34';

sub AUTOLOAD {
    if (@_ > 1) {
	$AutoLoader::AUTOLOAD = $AUTOLOAD;
	goto &AutoLoader::AUTOLOAD;
    }
    local($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    my ($pack,$file,$line) = caller;
	    die "Your vendor has not defined netCDF macro $constname, used at $file line $line.
";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap PDL::NetCDF $VERSION;


# Map a NetCDF type to a routine which will return a PDL of that type
my %typemap = (
	    NC_BYTE()   => $PDL::Core::PDL_B,
	    NC_CHAR()   => $PDL::Core::PDL_B,
	    NC_SHORT()  => $PDL::Core::PDL_S,
	    NC_LONG()   => $PDL::Core::PDL_L,
	    NC_FLOAT()  => $PDL::Core::PDL_F,
	    NC_DOUBLE() => $PDL::Core::PDL_D,
	    );

my %typemap1 = (
	     NC_BYTE()   => sub { byte   (@_); },
	     NC_CHAR()   => sub { byte   (@_); },
	     NC_SHORT()  => sub { short  (@_); },
	     NC_LONG()   => sub { long   (@_); },
	     NC_FLOAT()  => sub { float  (@_); },
	     NC_DOUBLE() => sub { double (@_); },
	    );

# This routine hooks up an object to a NetCDF file.
sub new {
  my $type = shift;
  my $file = shift;

  my $self = {};

  if (substr($file, 0, 1) eq '>') { # open for writing

    croak "Object-oriented write functions not yet implemented.  Use traditional interface";

    $file = substr ($file, 1);      # chop off >
    
    if (-e $file) {
      $self->{NCID} = ncopen ($file, NC_WRITE());
    } else {
      $self->{NCID} = nccreate ($file, NC_CLOBBER());
    }

    $self->{WR} = 'w';

  } else {                          # open for reading

    $self->{NCID} = ncopen ($file, NC_NOWRITE());
    $self->{WR}   = 'r';

  }

  bless $self, $type;
}
   

# Get a variable into a pdl
sub get {
  my $self  = shift;
  my $varnm = shift;
  my $start = shift;
  my $count = shift;

  # Cache varid
  if (!defined($self->{VARIDS}{$varnm})) {
    $self->{VARIDS}{$varnm} = ncvarid ($self->{NCID}, $varnm);
  }

  return ncvarget ($self->{NCID}, $self->{VARIDS}{$varnm}, $start, $count);
}


# Get the size of a dimension
sub dimsize {
  my $self  = shift;
  my $dimnm = shift;
  
  my ($dimsz, $name);
  ncdiminq ($self->{NCID}, ncdimid ($self->{NCID}, $dimnm), $name, $dimsz);
  
  return $dimsz;
}


# Get an attribute value into a pdl
sub getatt {
  my $self  = shift;
  my $attnm = shift;
  my $varnm = shift;
  
  # If no varnm passed in, fetch a global attribute
  my $varid;
  if (!defined($varnm)) { 
    $varnm = 'GLOBAL';
    $self->{VARIDS}{$varnm} = NC_GLOBAL();
  } else {
    if (!defined($self->{VARIDS}{$varnm})) {
      $self->{VARIDS}{$varnm} = ncvarid ($self->{NCID}, $varnm);
    }
  }

  # Determine the type of this variable
  my ($datatype, $len, $rc);
  $datatype = $len = '';
  $rc = ncattinq ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, $datatype, $len);
  
  if ($rc != 0) {
    warn "getatt: Cannot get attribute info";
    return undef;
  }

  if ($datatype == NC_CHAR()) {
    my $str = '';
    $rc = ncattget ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, \$str);

    if ($rc != 0) {
      warn "getatt: Cannot get attribute";
      return undef;
    }
   
    return $str;
  }

  my @list = ();
  $rc = ncattget ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, \@list);

  if ($rc != 0) {
    warn "getatt: Cannot get attribute";
    return undef;
  }

  my $pdl = &{$typemap1{$datatype}}([@list]);
  
  return $pdl;

}

sub DESTROY {
  my $self = shift;
  # print "Closing NCID = $self->{NCID}\n";
  ncclose ($self->{NCID});
}

#--------------------------------------------------------------
# Start of (perl part of) traditional interface
#--------------------------------------------------------------


# This routine quickly creates a PDL object of the correct type.
# This would better be done in the PDL code itself.  The
# PDL::zeroes routine always defaults to float--it should be
# made flexible enough to create any type PDL.
# This routine pretends it is in class PDL.
#
# Create zero filled array (function/inheritable constructor).
# Allow user to specify the type of the PDL
sub typed_zeroes {
  my $class = shift;  
  my $shape = shift;
  my $type  = shift;
  if (!defined($type)) { $type = $PDL::Core::PDL_F; } # default to float
  
  my $nelems = 1; my @dims;
  for (@$shape) { 
    croak "Dimensions must be positive" if $_<=0;
    $nelems *= $_; push @dims, $_ 
    }
  my $pdl = bless {}, $class;
  $$pdl{Data}     = "\0"x($nelems*PDL::Core::howbig($type));
  $$pdl{Datatype} = $type;
  $$pdl{Dims}     = [@dims];
  return $pdl;
} 


# Get a variable into a pdl.
sub ncvarget {
  my $ncid  = shift;
  my $varid = shift;
  my $start = shift;
  my $count = shift;

  # Determine the type of this variable
  my ($name, $datatype, $ndims, $natts, $i);
  $datatype = $name = $ndims = $natts = '';
  my @dimids = ();
  my $rc = 0;
  $rc = ncvarinq ($ncid, $varid, $name, $datatype, $ndims, \@dimids, $natts);
  croak "Cannot get info on this var id" if ($rc != 0); 

  # If no start and count are specified, load the whole matrix to a PDL
  # Find out size of each dimension of this NetCDF matrix
  if (!defined($start)) {
    for ($i=0;$i<$ndims;$i++) {
      my ($name, $size);
      ncdiminq ($ncid, $dimids[$i], $name, $size);
      push (@$count, $size);
      push (@$start, 0);
    }
  }

  # Create empty PDL (of correct type and size) to hold output from NetCDF file
  my @cnt = grep {$_ != 1} @$count; # Get rid of length-one dimensions
  if (@cnt == 0) { $cnt[0] = 1; }   # If no dimensions left, add one single length one.
  my $pdl = typed_zeroes('PDL', [reverse @cnt], $typemap{$datatype});

  # Get the data
  $rc = ncvargetscalar($ncid, $varid, $start, $count, $pdl->{Data});
  croak "Cannot get data from this var id" if ($rc != 0); 
  
  return $pdl;
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME 

PDL::NetCDF - Interface NetCDF files to PDL objects.

Perl extension to allow interface to NetCDF portable
binary gridded files via PDL objects.

=head1 SYNOPSIS

  # This is the 'traditional' interface for reading and writing NetCDF from/into PDLs:

  use PDL;
  use PDL::NetCDF qw(/^nc/ /^NC_/);
  $ncid   = nccreate('file.nc', NC_CLOBBER);
  $dim1id = ncdimdef($ncid, 'Dim1', 3);
  $var1id = ncvardef($ncid, 'Var1', NC_FLOAT, [$dim1id]);
  ncendef($ncid);
  ncvarput($ncid, $var1id, [0], [3], float [0..2]);
  ncclose($ncid);

  ...

  $ncid  = ncopen('file.nc', NC_RDWR);
  $dimid = ncdimid($ncid, 'Dim1');
  $varid = ncvarid($ncid, 'Var1');
  $p1    = ncvarget($ncid, $varid, [0], [3]); 
   
  print $p1; # This is a PDL object of type float
  # yields [0, 1, 2]


  # This is the object oriented interface (for reading only):

  use PDL;
  use PDL::NetCDF;
  $obj = NetCDF::PDL->new ('file.nc');

  $p1  = $obj->get('Var1');
  print $p1;
  # yields [0, 1, 2]

  $dimsize = $obj->dimsize('dimname');

  # This attribute will be a PDL or a string depending on its NetCDF type.
  $attribute = $obj->getatt('attname', 'varname');

  # One can also get global attributes using:
  $global_attribute = $obj->getatt('attname');


  For (much) more information on NetCDF, see 

  http://www.unidata.ucar.edu/packages/netcdf/index.html
  
  Also see the test file, test.pl in this distribution.

=head1 DESCRIPTION

This is the PDL interface to the Unidata NetCDF library.
It is largely a copy of the original netcdf-perl (available through
Unidata at http://www.unidata.ucar.edu/packages/netcdf/index.html).

The NetCDF standard allows N-dimensional binary data to be efficiently
stored, annotated and exchanged between many platforms.

The original interface has been left largely intact (see the netcdf
users manual, available at the above URL for more information.  The
manual documents the C interface, but the perl interface is almost 
identical) except for two functions:

ncvarget (get a hyperslab of data) and
ncvarput (put a hyperslab of data).

These two have been modified to receive and deliver PDL objects.
(The originals returned one-dimensional perl lists, which was
quite inefficient for large data sets.  The flattening of N
dimensional data was also irksome).

This version of the PDL interface also offers an object-oriented read-only
interface to NetCDF.  One must still write NetCDF files using the old
style interface, but reading of NetCDF files is considerably simplified.

Use the function: 

PDL::NetCDF->new ('file.nc') 

to create a NetCDF file object.  Then use 

$obj->get('varname') 
$obj->getatt ('attname', 'varname') 

to get variables or attributes into PDLs.  

=head1 AUTHOR

Doug Hunt, dhunt@ucar.edu for the PDL version.  
Steve Emmerson (UCAR UniData) for the original version

=head1 SEE ALSO

perl(1), netcdf(3).

=cut
