
#
# GENERATED WITH PDL::PP! Don't modify!
#
package PDL::NetCDF;

@EXPORT_OK  = qw( );
%EXPORT_TAGS = (Func=>[@EXPORT_OK]);

use PDL::Core;
use PDL::Exporter;
use DynaLoader;



   
   @ISA    = ( 'PDL::Exporter','DynaLoader' );
   push @PDL::Core::PP, __PACKAGE__;
   bootstrap PDL::NetCDF ;




=head1 NAME 

PDL::NetCDF - Object-oriented interface between NetCDF files and PDL objects.

Perl extension to allow interface to NetCDF portable
binary gridded files via PDL objects.

=head1 SYNOPSIS

  use PDL;
  use PDL::NetCDF;
  use PDL::Char;

  my $ncobj = PDL::NetCDF->new ("test.nc");  # New file
  my $pdl = pdl [[1, 2, 3], [4, 5, 6]];

  # Specify variable name to put PDL in, plus names of the dimensions.  Dimension         
  # lengths are taken from the PDL, in this case, dim1 = 2 and dim2 = 3.      
  $ncobj->put ('var1', ['dim1', 'dim2'], $pdl);                                               

  # $pdlout = [[1, 2, 3], [4, 5, 6]]
  my $pdlout = $ncobj->get ('var1');

  # Store textual NetCDF arrays using perl strings:  (This is a bit primitive, but works)
  my $str = "Station1  Station2  Station3  ";
  $obj->puttext('textvar', ['n_station', 'n_string'], [3,10], $str);
  my $outstr = $obj->gettext('textvar');
  # $outstr = "Station1  Station2  Station3  "


  # Now textual NetCDF arrays can be stored with PDL::Char style PDLs.  This is much
  # more natural and flexible than the above method.
  $str = PDL::Char->new (['Station1', 'Station2', 'Station3']);
  $obj->put ('stations', ['dim_station', 'dim_charlen'], $str);
  $outstr = $obj->get('stations');
  print $outstr;
  # Prints: ['Station1', 'Station2', 'Station3']
  # For more info on PDL::Char variables see PDL::Char(3), or perldoc PDL::Char

  # $dim1size = 2
  my $dim1size = $ncobj->dimsize('dim1');

  # A slice of the netCDF variable.
  # [0,0] is the starting point, [1,2] is the count.
  # $slice = [1,2]
  my $slice  = $ncobj->get ('var1', [0,0], [1,2]);

  # Attach a double attribute of size 3 to var1
  $ncobj->putatt (double([1,2,3]), 'double_attribute', 'var1');

  # $attr1 = [1,2,3]
  my $attr1 = $ncobj->getatt ('double_attribute', 'var1');

  # Write a textual, global attribute.  'attr_name' is the attribute name.
  $ncobj->putatt ('The text of the global attribute', 'attr_name');          

  # $attr2 = 'The text of the global attribute'
  my $attr2 = $ncobj->getatt ('attr_name');

  # Close the netCDF file.  The file is also automatically closed in a DESTROY block
  # when it passes out of scope.  This just makes is explicit.
  $ncobj->close;

For (much) more information on NetCDF, see 

http://www.unidata.ucar.edu/packages/netcdf/index.html 

Also see the test file, test.pl in this distribution for some working examples.

=head1 DESCRIPTION

This is the PDL interface to the Unidata NetCDF library.  It uses the
netCDF version 3 library to make a subset of netCDF functionality
available to PDL users in a clean, object-oriented interface.

Another NetCDF perl interface, which allows access to the entire range
of netCDF functionality (but in a rather C-ish non-object-oriented
style) is available through Unidata at
http://www.unidata.ucar.edu/packages/netcdf/index.html).

The NetCDF standard allows N-dimensional binary data to be efficiently
stored, annotated and exchanged between many platforms.

When one creates a new netCDF object, this object is associated with one
netCDF file.  

=head1 FUNCTIONS

=head2 new

=for ref

Create an object representing a netCDF file.

=for usage      	

 Arguments:  
 1) The name of the file.
 2) (optional) An existing netCDF object for a file with
    identical layout.  This allows one to read in many similar netCDF
    files without incurring the overhead of reading in all variable
    and dimension names and IDs each time.  Caution:  Undefined
    weirdness may occur if you pass the netCDF object from a dissimilar
    file!

Example:

  my $nc = PDL::NetCDF->new ("file1.nc");
  ...
  foreach my $ncfile (@a_bunch_of_similar_format_netcdf_files) {
    $nc = PDL::NetCDF->new("file2.nc", $nc);  # These calls to 'new' are *much* faster
    ...
  }

If this file exists and you want to write to it, 
prepend the name with the '>' character:  ">name.nc"

Returns:  The netCDF object.  Barfs if there is an error.

=for example
  $ncobj = PDL::NetCDF->new ("file.nc");

=head2 put        

=for ref

Put a PDL matrix to a netCDF variable.

=for usage

Arguments:  

1) The name of the variable to create

2) A reference to a list of dimension names for this variable

3) The PDL to put.  It must have the same number of dimensions
as specified in the dimension name list.

Returns:
None.

=for example

  my $pdl = pdl [[1, 2, 3], [4, 5, 6]];

  # Specify variable name to put PDL in, plus names of the dimensions.  Dimension         
  # lengths are taken from the PDL, in this case, dim1 = 2 and dim2 = 3.      
  $ncobj->put ('var1', ['dim1', 'dim2'], $pdl);                                               
                                            
  # Now textual NetCDF arrays can be stored with PDL::Char style PDLs.  
  $str = PDL::Char->new (['Station1', 'Station2', 'Station3']);
  $obj->put ('stations', ['dim_station', 'dim_charlen'], $str);
  $outstr = $obj->get('stations');
  print $outstr;
  # Prints: ['Station1', 'Station2', 'Station3']
  # For more info on PDL::Char variables see PDL::Char(3), or perldoc PDL::Char

=head2 putslice

=for ref

Put a PDL matrix to a slice of a NetCDF variable

=for usage

Arguments:

1) The name of the variable to create

2) A reference to a list of dimension names for this variable

3) A reference to a list of dimensions for this variable

4) A reference to a list which specifies the N dimensional starting point of the slice.

5) A reference to a list which specifies the N dimensional count of the slice.

6) The PDL to put.  It must conform to the size specified by the 4th and 5th
   arguments.  The 2nd and 3rd argument are optional if the variable is already
   defined in the netcdf object. 

Returns:
None.

=for example

  my $pdl = pdl [[1, 2, 3], [4, 5, 6]];

  # Specify variable name to put PDL in, plus names of the dimensions.  Dimension         
  # lengths are taken from the PDL, in this case, dim1 = 2 and dim2 = 3.      
  $ncobj->putslice ('var1', ['dim1', 'dim2', 'dim3'], [2,3,3], [0,0,0], [2,3,1], $pdl);                                               
  $ncobj->putslice ('var1', [], [], [0,0,2], [2,3,1], $pdl);                                               

  my $pdl2 = $ncobj->get('var1');

  print $pdl2;

  [
 [
  [          1 9.96921e+36           1]
  [          2 9.96921e+36           2]
  [          3 9.96921e+36           3]
 ]
 [
  [          4 9.96921e+36           4]
  [          5 9.96921e+36           5]
  [          6 9.96921e+36           6]
 ]
]

 note that the netcdf missing value (not 0) is filled in.    

=head2 get

=for ref

Get a PDL matrix from a netCDF variable.

=for usage

Arguments:  

1) The name of the netCDF variable to fetch.  If this is the only
argument, then the entire variable will be returned.

To fetch a slice of the netCDF variable, optional 2nd and 3rd argments
must be specified:

2) A pdl which specifies the N dimensional starting point of the slice.

3) A pdl which specifies the N dimensional count of the slice.

Returns:
The PDL representing the netCDF variable.  Barfs on error.

=for example

  # A slice of the netCDF variable.
  # [0,0] is the starting point, [1,2] is the count.
  my $slice  = $ncobj->get ('var1', [0,0], [1,2]);

  # If var1 contains this:  [[1, 2, 3], [4, 5, 6]]
  # Then $slice contains: [1,2] (Size '1' dimensions are eliminated).

=head2 putatt

=for ref

putatt -- Attach a numerical or textual attribute to a NetCDF variable or the entire file.

=for usage

Arguments:

1) The attribute.  Either:  A one dimensional PDL (perhaps contining only one number) or
a string.

2) The name to give the attribute in the netCDF file.  Many attribute names
have pre-defined meanings.  See the netCDF documentation for more details.

3) Optionally, you may specify the name of the pre-defined netCDF variable to associate
this attribute with.  If this is left off, the attribute is a global one, pertaining to
the entire netCDF file.

Returns:
Nothing.  Barfs on error.

=for example

  # Attach a double attribute of size 3 to var1
  $ncobj->putatt (double([1,2,3]), 'double_attribute', 'var1');

  # Write a textual, global attribute.  'attr_name' is the attribute name.
  $ncobj->putatt ('The text of the global attribute', 'attr_name');          

=head2 getatt

=for ref

Get an attribute from a netCDF object.

=for usage

Arguments:

1) The name of the attribute (a text string).

2) The name of the variable this attribute is attached to.  If this
argument is not specified, this function returns a global attribute of
the input name.

=for example

  # Get a global attribute
  my $attr2 = $ncobj->getatt ('attr_name');

  # Get an attribute associated with the varibale 'var1'
  my $attr1 = $ncobj->getatt ('double_attribute', 'var1');

=head2 puttext

=for ref

Put a perl text string into a multi-dimensional NetCDF array.

=for usage

Arguments:

1) The name of the variable to be created (a text string).

2) A reference to a perl list of dimension names to use in creating this NetCDF array.

3) A reference to a perl list of dimension lengths.

4) A perl string to put into the netCDF array.  If the NetCDF array is 3 x 10, then the string must
   have 30 charactars.  

=for example

  my $str = "Station1  Station2  Station3  ";
  $obj->puttext('textvar', ['n_station', 'n_string'], [3,10], $str);

=head2 gettext

=for ref

Get a multi-dimensional NetCDF array into a perl string.

=for usage

Arguments:

1) The name of the NetCDF variable.

=for example

  my $outstr = $obj->gettext('textvar');

=head2 dimsize

=for ref

Get the size of a dimension from a netCDF object.

=for usage

Arguments:

1) The name of the dimension.

Returns:
The size of the dimension.

=for example

  my $dim1size = $ncobj->dimsize('dim1');

=head2 close

=for ref

Close a NetCDF object, writing out the file.

=for usage

Arguments:
None

Returns:
Nothing

This closing of the netCDF file can be done explicitly though the
'close' method.  Alternatively, a DESTROY block does an automatic
close whenever the netCDF object passes out of scope.

=for example

  $ncobj->close();

=head2 getdimensionnames ([$varname])

=for ref

Get all the dimension names from an open NetCDF object.  
If a variable name is specified, just return dimension names for
*that* variable.

=for usage

Arguments:
none

Returns:
An array reference of dimension names

=for example
  
  my $varlist = $ncobj->getdimensionnames();
  foreach(@$varlist){
    print "Found dim $_\n";
  }

=head2 getattributenames

=for ref

Get the attribute names for a given variable from an open NetCDF object.

=for usage

Arguments:
Optional variable name, with no arguments it will return the objects global netcdf attributes.

Returns:
An array reference of attribute names

=for example
  
  my $attlist = $ncobj->getattributenames('var1');

=head2 getvariablenames

=for ref

Get all the variable names for an open NetCDF object.

=for usage

Arguments:
 none.

Returns:
An array reference of variable names

=for example
  
  my $varlist = $ncobj->getvariablenames();

=head1 AUTHOR

Doug Hunt, dhunt\@ucar.edu.

=head1 SEE ALSO

perl(1), PDL(1), netcdf(3).

=cut







# Used for creating new blank pdls with the input number of dimensions, and
# the correct type.
my %typemap = (
	       NC_BYTE()   => sub { PDL->zeroes (PDL::byte,   @_); },
	       NC_CHAR()   => sub { PDL::Char->new(PDL->zeroes (PDL::byte,   @_)); },
	       NC_SHORT()  => sub { PDL->zeroes (PDL::short,  @_); },
	       NC_INT()    => sub { PDL->zeroes (PDL::long,   @_); },
	       NC_FLOAT()  => sub { PDL->zeroes (PDL::float,  @_); },
	       NC_DOUBLE() => sub { PDL->zeroes (PDL::double, @_); },
	       );

# Used for creating new pdls with the input data, and
# the correct type.
my %typemap1 = (
		NC_BYTE()   => sub { PDL::byte  (@_); },
		NC_CHAR()   => sub { PDL::byte  (@_); },
		NC_SHORT()  => sub { PDL::short (@_); },
		NC_INT()    => sub { PDL::long  (@_); },
		NC_FLOAT()  => sub { PDL::float (@_); },
		NC_DOUBLE() => sub { PDL::double(@_); },
		);

# Used for creating new blank pdls with the input number of dimensions, and
# the correct type.
my %typemap2 = (
		PDL::byte->[0]   => sub { return PDL::NetCDF::nc_put_var_uchar  (@_); },
		PDL::short->[0]  => sub { return PDL::NetCDF::nc_put_var_short  (@_); },
		PDL::long->[0]   => sub { return PDL::NetCDF::nc_put_var_int    (@_); },
		PDL::float->[0]  => sub { return PDL::NetCDF::nc_put_var_float  (@_); },
		PDL::double->[0] => sub { return PDL::NetCDF::nc_put_var_double (@_); },
		);


# Used for mapping a PDL type to a netCDF type
my %typemap3 = (
		PDL::byte->[0]   => NC_BYTE(), 
		PDL::short->[0]  => NC_SHORT(), 
		PDL::long->[0]   => NC_INT(), 
		PDL::float->[0]  => NC_FLOAT(), 
		PDL::double->[0] => NC_DOUBLE(), 
		);

# Used for getting a netCDF variable for the correct type of a PDL
my %typemap4 = (
		PDL::byte->[0]   => sub { PDL::NetCDF::nc_get_var_uchar  (@_); },
		PDL::short->[0]  => sub { PDL::NetCDF::nc_get_var_short  (@_); },
		PDL::long->[0]   => sub { PDL::NetCDF::nc_get_var_int    (@_); },
		PDL::float->[0]  => sub { PDL::NetCDF::nc_get_var_float  (@_); },
		PDL::double->[0] => sub { PDL::NetCDF::nc_get_var_double (@_); },
		);

# Used for putting attributes of correct type for a PDL
my %typemap5 = (
		PDL::byte->[0]   => sub { return PDL::NetCDF::nc_put_att_uchar  (@_); },
		PDL::short->[0]  => sub { return PDL::NetCDF::nc_put_att_short  (@_); },
		PDL::long->[0]   => sub { return PDL::NetCDF::nc_put_att_int    (@_); },
		PDL::float->[0]  => sub { return PDL::NetCDF::nc_put_att_float  (@_); },
		PDL::double->[0] => sub { return PDL::NetCDF::nc_put_att_double (@_); },
		);

# Used for getting a netCDF attribute for the correct type of a PDL
my %typemap6 = (
		PDL::byte->[0]   => sub { PDL::NetCDF::nc_get_att_uchar  (@_); },
		PDL::short->[0]  => sub { PDL::NetCDF::nc_get_att_short  (@_); },
		PDL::long->[0]   => sub { PDL::NetCDF::nc_get_att_int    (@_); },
		PDL::float->[0]  => sub { PDL::NetCDF::nc_get_att_float  (@_); },
		PDL::double->[0] => sub { PDL::NetCDF::nc_get_att_double (@_); },
		);

# Used for getting a slice of a netCDF variable for the correct type of a PDL 
my %typemap7 = (
		PDL::byte->[0]   => sub { PDL::NetCDF::nc_get_vara_uchar  (@_); },
		PDL::short->[0]  => sub { PDL::NetCDF::nc_get_vara_short  (@_); },
		PDL::long->[0]   => sub { PDL::NetCDF::nc_get_vara_int    (@_); },
		PDL::float->[0]  => sub { PDL::NetCDF::nc_get_vara_float  (@_); },
		PDL::double->[0] => sub { PDL::NetCDF::nc_get_vara_double (@_); },
		);

# Used for putting a slice of a netCDF variable for the correct type of a PDL 
my %typemap8 = (
		PDL::byte->[0]   => sub { PDL::NetCDF::nc_put_vara_uchar  (@_); },
		PDL::short->[0]  => sub { PDL::NetCDF::nc_put_vara_short  (@_); },
		PDL::long->[0]   => sub { PDL::NetCDF::nc_put_vara_int    (@_); },
		PDL::float->[0]  => sub { PDL::NetCDF::nc_put_vara_float  (@_); },
		PDL::double->[0] => sub { PDL::NetCDF::nc_put_vara_double (@_); },
		);

# This routine hooks up an object to a NetCDF file.
sub new {
  my $type = shift;
  my $file = shift;
  my $self = shift;

  my $fast = 0;  # fast new does not inquire about all variables and dimensions.
                 # This is assumed to have been done before.  All this info
                 # is taken from the previous nc object.  This is useful
	         # if one has to process many identical netCDF files.

  if (defined($self)) {
    $fast = 1;
  } else {
    $self = {};
  }

  my $rc;
  my $write;

  if (substr($file, 0, 1) eq '>') { # open for writing
    $file = substr ($file, 1);      # chop off >
    $write = 1;
  }
    
  if (-e $file) {

    if ($write) {

      $rc = PDL::NetCDF::nc_open ($file, NC_WRITE(), $self->{NCID}=-999);
      barf ("new:  Cannot open file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
      $self->{WR} = 'w';

    } else { # Open read-only

      $rc = PDL::NetCDF::nc_open ($file, 0, $self->{NCID}=-999);
      barf ("new:  Cannot open file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
      $self->{WR} = 'r';

      # Specify that this file is out of define mode
      $self->{DEFINE} = 0;

    }

    # Record file name
    $self->{FILENM} = $file;

    # don't bother to inquire about this file.  The info in the nc object 
    # passed in should suffice.
    return $self if ($fast);

    # Find out about variables, dimensions and global attributes in this file
    my ($ndims, $nvars, $ngatts, $unlimid);

#    $rc = PDL::NetCDF::nc_inq_ndims ($self->{NCID}, $ndims=-999);
#    barf ("new:  Cannot inquire ndims -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
#    $rc = PDL::NetCDF::nc_inq_nvars ($self->{NCID}, $nvars=-999);
#    barf ("new:  Cannot inquire nvars -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;

    $rc = PDL::NetCDF::nc_inq ($self->{NCID}, $ndims=-999, $nvars=-999, $ngatts=-999, $unlimid=-999);
    barf ("new:  Cannot inquire -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;

    
    for (my $i=0;$i<$ndims;$i++) {
      $rc = PDL::NetCDF::nc_inq_dimname ($self->{NCID}, $i, 
					 my $name='x' x NC_MAX_NAME()); # Preallocate strings
      barf ("new:  Cannot inquire dim name -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
      $self->{DIMIDS}{$name} = $i;
      
      $rc = PDL::NetCDF::nc_inq_dimlen ($self->{NCID}, $i, my $len = -999);
      barf ("new:  Cannot inquire dim length -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
      $self->{DIMLENS}{$name} = $len;
    }
    
    for (my $i=0;$i<$nvars;$i++) {
      $rc = PDL::NetCDF::nc_inq_varname ($self->{NCID}, $i, 
					 my $name='x' x NC_MAX_NAME()); # Preallocate strings
      barf ("new:  Cannot inquire var name -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
      $self->{VARIDS}{$name} = $i;

      $rc  = PDL::NetCDF::nc_inq_vartype ($self->{NCID}, $self->{VARIDS}{$name}, 
					     $self->{DATATYPES}{$name}=-999);
      barf ("new:  Cannot inquire var type -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
      
      $rc = PDL::NetCDF::nc_inq_varnatts ($self->{NCID}, $i,
                                       my $natts=-999);
      barf ("new:  Cannot inquire natts -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
      for (my $j=0;$j<$natts; $j++) {
        $rc = PDL::NetCDF::nc_inq_attname ($self->{NCID}, $i, $j,
                                       my $attname='x' x NC_MAX_NAME()); # Preallocate strings
        barf ("new:  Cannot inquire att name -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	

        # Determine the type and length of this attribute
        $rc = PDL::NetCDF::nc_inq_atttype ($self->{NCID}, $i, $attname, my $datatype=-999);
        barf ("new:  Cannot get attribute type -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

        $rc = PDL::NetCDF::nc_inq_attlen ($self->{NCID}, $i, $attname, my $attlen=-999);
        barf ("new:  Cannot get attribute length -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  


        $self->{ATTTYPE}{$name}{$attname}=$datatype;
        $self->{ATTLEN}{$name}{$attname}=$attlen;
      }

    }
    
    for (my $i=0;$i<$ngatts; $i++) {
      $self->{VARIDS}{GLOBAL}=NC_GLOBAL();
      $rc = PDL::NetCDF::nc_inq_attname ($self->{NCID},$self->{VARIDS}{GLOBAL} , $i,
                                       my $attname='x' x NC_MAX_NAME()); # Preallocate strings
      barf ("new:  Cannot inquire global att name -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	


        # Determine the type and length of this attribute
        $rc = PDL::NetCDF::nc_inq_atttype ($self->{NCID}, $self->{VARIDS}{GLOBAL}, $attname, my $datatype=-999);
        barf ("new:  Cannot get attribute type -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

        $rc = PDL::NetCDF::nc_inq_attlen ($self->{NCID}, $self->{VARIDS}{GLOBAL}, $attname, my $attlen=-999);
        barf ("new:  Cannot get attribute length -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  


        $self->{ATTTYPE}{GLOBAL}{$attname}=$datatype;
        $self->{ATTLEN}{GLOBAL}{$attname}=$attlen;
    } 
  


    # Specify that this file is out of define mode
    $self->{DEFINE} = 0;
    
  } else { # new file
    
    $rc = PDL::NetCDF::nc_create ($file, NC_CLOBBER(), $self->{NCID}=-999);
    barf ("new:  Cannot create netCDF file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;	
    
    # Specify that this file is now in define mode
    $self->{DEFINE} = 1;

    # Open for writing
    $self->{WR} = 'w';

  }
  
  # Record file name
  $self->{FILENM} = $file;

  bless $self, $type;
  return $self;
}

# Explicitly close a netCDF file and free the object
sub close {
  my $self = shift;
  return PDL::NetCDF::nc_close ($self->{NCID});
}

# Close a netCDF object when it passes out of scope
sub DESTROY {
  my $self = shift;
  # print "Destroying $self\n";
  $self->close;
}

# Get the names and order of dimensions in a variable, otherwise
# get the names of all dimensions
sub getdimensionnames {
  my $self = shift;
  my $varnm = shift;
  my $dimnames = [];
  my $dimids = [values %{$self->{DIMIDS}}];
  if (defined $varnm) {
    my $ndims;
    my $rc = PDL::NetCDF::nc_inq_varndims ($self->{NCID}, $self->{VARIDS}{$varnm}, $ndims=-999);


    if ($ndims > 0) {
      $dimids = zeroes (PDL::long, $ndims);
      $rc |= PDL::NetCDF::nc_inq_vardimid ($self->{NCID}, $self->{VARIDS}{$varnm}, $dimids);
      barf ("getdimensionnames:  Cannot get info on this var id -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
      $dimids = [list $dimids];
    } else {
      $dimids = [];
    }
  }
  foreach my $id (@$dimids) {
    foreach(keys %{$self->{DIMIDS}}){
      push(@$dimnames,$_) if $self->{DIMIDS}{$_} == $id;
    }
  }
  $dimnames;
}

# Return the names of all variables in the netCDF file.
sub getvariablenames {
  my $self = shift;
  my $varnames = [];
  foreach(keys %{$self->{VARIDS}}){
    next if($self->{VARIDS}{$_} == NC_GLOBAL());
    push(@$varnames,$_);
  }
  $varnames;
} 

# Return the names of all attribute names in the netCDF file.
sub getattributenames {
  my $self = shift;
  my $varname = shift;
  $varname = 'GLOBAL' unless(defined $varname);
  my $attnames = [];
  foreach(keys %{$self->{ATTTYPE}{$varname}}){
        push(@$attnames,$_);
  }
  $attnames;
} 

# Put a netCDF variable from a PDL
sub put {
  my $self  = shift;  # name of object
  my $varnm = shift;  # name of netCDF variable to create or update
  my $dims  = shift;  # set of dimensions, i.e. ['dim1', 'dim2']
  my $pdl   = shift;  # PDL to put

  barf "Cannot write read-only netCDF file $self->{FILENM}" if ($self->{WR} eq 'r');

  # Define dimensions if necessary

  my @dimlens = reverse $pdl->dims;

  my $dimids = (@dimlens > 0) ? zeroes (PDL::long, scalar(@dimlens)) : pdl [];

  for (my $i=0;$i<@$dims;$i++) {
    if (!defined($self->{DIMIDS}{$$dims[$i]})) {

      unless ($self->{DEFINE}) {
	my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
	barf ("Cannot put file into define mode") if $rc;
	$self->{DEFINE} = 1;
      }


      my $rc = PDL::NetCDF::nc_def_dim ($self->{NCID}, $$dims[$i], $dimlens[$i], 
				$self->{DIMIDS}{$$dims[$i]}=-999);
      barf ("put:  Cannot define dimension -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;

      $self->{DIMLENS}{$$dims[$i]} = $dimlens[$i];

    }
    set ($dimids, $i, $self->{DIMIDS}{$$dims[$i]});

    barf ("put:  Attempt to redefine length of dimension $$dims[$i]") 
      if ($self->{DIMLENS}{$$dims[$i]} != $dimlens[$i]);
    
  }

  # Define variable if necessary
  if (!defined($self->{VARIDS}{$varnm})) {
  
    unless ($self->{DEFINE}) {
      my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
      barf ("put:  Cannot put file into define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
      $self->{DEFINE} = 1;
    }

    my $datatype;
    if (ref($pdl) =~ /Char/) {  # a PDL::Char type PDL--write a netcdf char variable
      $datatype = NC_CHAR();
    } else {
      $datatype = $typemap3{$pdl->get_datatype};
    }
    my $rc = PDL::NetCDF::nc_def_var ($self->{NCID}, $varnm, $datatype, 
			   scalar(@dimlens), $dimids, $self->{VARIDS}{$varnm}=-999);
    barf ("put:  Cannot define variable -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

    $self->{DATATYPES}{$varnm} = $datatype;

  }

  # Make PDL physical
  $pdl->make_physical;

  # Get out of define mode
  if ($self->{DEFINE}) {
    my $rc = PDL::NetCDF::nc_enddef ($self->{NCID});
    barf ("put:  Cannot end define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    $self->{DEFINE} = 0;
  }

  # Call the correct 'put' routine depending on PDL type
  if (ref($pdl) =~ /Char/) {  # a PDL::Char type PDL--write a netcdf char variable
    $rc = PDL::NetCDF::nc_put_var_text ($self->{NCID}, $self->{VARIDS}{$varnm}, ${$pdl->get_dataref}."\0"); # null terminate!
  } else {
    $rc = &{$typemap2{$pdl->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, $pdl);
  }
  barf ("put:  Cannot write file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  $rc = PDL::NetCDF::nc_sync($self->{NCID});
  barf ("put:  Cannot sync file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

  return 0;

}

#
# Put a netCDF variable slice (array section) from a PDL
# 
sub putslice {
  my $self  = shift;  # name of object
  my $varnm = shift;  # name of netCDF variable to create or update

  my $dims  = shift;  # set of dimensions, i.e. ['dim1', 'dim2']
  my $dimdefs = shift;# Need to state dims explicitly since the PDL is a subset

  my $start = shift;  # ref to perl array containing start of hyperslab to get
  my $count = shift;  # ref to perl array containing count along each dimension

  my $pdl   = shift;  # PDL to put

  barf "Cannot write read-only netCDF file $self->{FILENM}" if ($self->{WR} eq 'r');

  if (!defined($self->{VARIDS}{$varnm})) {

  # Define dimensions if necessary
  my @dimlens =  @$dimdefs;

  my $dimids = zeroes (PDL::long, scalar(@dimlens));
  for (my $i=0;$i<@$dims;$i++) {
    if (!defined($self->{DIMIDS}{$$dims[$i]})) {

      unless ($self->{DEFINE}) {
	my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
	barf ("Cannot put file into define mode") if $rc;
	$self->{DEFINE} = 1;
      }


      my $rc = PDL::NetCDF::nc_def_dim ($self->{NCID}, $$dims[$i], $dimlens[$i], 
				$self->{DIMIDS}{$$dims[$i]}=-999);
      barf ("put:  Cannot define dimension -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;

      $self->{DIMLENS}{$$dims[$i]} = $dimlens[$i];

    }
    set ($dimids, $i, $self->{DIMIDS}{$$dims[$i]});

    barf ("putslice:  Attempt to redefine length of dimension $$dims[$i]") 
      if ($self->{DIMLENS}{$$dims[$i]} != $dimlens[$i]);
    
  }

  # Define variable if necessary

    unless ($self->{DEFINE}) {
      my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
      barf ("put:  Cannot put file into define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
      $self->{DEFINE} = 1;
    }
    my $datatype;
    if (ref($pdl) =~ /Char/) {  # a PDL::Char type PDL--write a netcdf char variable
      $datatype = NC_CHAR();
    } else {
      $datatype = $typemap3{$pdl->get_datatype};
    }

    my $rc = PDL::NetCDF::nc_def_var ($self->{NCID}, $varnm, $datatype, 
			   scalar(@dimlens), $dimids, $self->{VARIDS}{$varnm}=-999);
    barf ("put:  Cannot define variable -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

    $self->{DATATYPES}{$varnm} = $datatype;

  }


  # Make PDL physical
  $pdl->make_physical;

  # Get out of define mode
  if ($self->{DEFINE}) {
    my $rc = PDL::NetCDF::nc_enddef ($self->{NCID});
    barf ("put:  Cannot end define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    $self->{DEFINE} = 0;
  }

    # Convert start and count from perl lists to scalars



    my $st = pack ("L*", @$start);
    my $ct = pack ("L*", @$count);


  # Call the correct 'put' routine depending on PDL type
  if(ref($pdl) =~ /Char/)  {  # a PDL::Char type PDL--write a netcdf char variable
    $rc = PDL::NetCDF::nc_put_vara_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, ${$pdl->get_dataref}."\0"); # null terminate!
  } else {
    $rc = &{$typemap8{$pdl->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, $pdl);
  }
  barf ("put:  Cannot write file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  $rc = PDL::NetCDF::nc_sync($self->{NCID});
  barf ("put:  Cannot sync file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

  return 0;

}


# Get a variable into a pdl
sub get {
  my $self  = shift;
  my $varnm = shift;

  my $rc = 0;

  # Optional variables
  my $start = shift;  # ref to perl array containing start of hyperslab to get
  my $count = shift;  # ref to perl array containing count along each dimension

  barf ("Cannot find variable $varnm") if (!defined($self->{VARIDS}{$varnm}));

  my $pdl; # The PDL to return
  if (defined ($count)) {  # Get a hyperslab of the netCDF matrix

    # Get rid of length one dimensions.  @cnt used for allocating new blank PDL
    # to put data in.
    my @cnt = ();
    foreach my $elem (@$count) {
      push (@cnt, $elem) if ($elem != 1);
    }
    if (@cnt == 0) { @cnt = (1); }  # If count all ones, replace with single one

    # Note the 'reverse'! Necessary fiddling to get dimension order to work.
    $pdl = &{$typemap{$self->{DATATYPES}{$varnm}}}(reverse @cnt);	

    # Convert start and count from perl lists to scalars



    my $st = pack ("L*", @$start);
    my $ct = pack ("L*", @$count);



    # Get the data
    if (ref($pdl) =~ /Char/) {  # a PDL::Char type PDL--write a netcdf char variable
      my $f = ${$pdl->get_dataref}; 
      $rc = PDL::NetCDF::nc_get_vara_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, $f);
      ${$pdl->get_dataref} = $f;	
      $pdl->upd_data();
    } else {
      $rc = &{$typemap7{$pdl->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, $pdl);
    }
    barf ("get:  Cannot get data -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

  } else { # get whole netCDF matrix

    # Determine the type of this variable
    my ($ndims, $natts, $i);
    $rc = PDL::NetCDF::nc_inq_varndims ($self->{NCID}, $self->{VARIDS}{$varnm}, $ndims=-999);
    my $dimids = ($ndims > 0) ? zeroes (PDL::long, $ndims) : pdl [];
    $rc |= PDL::NetCDF::nc_inq_vardimid ($self->{NCID}, $self->{VARIDS}{$varnm}, $dimids);
    barf ("get:  Cannot get info on this var id -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    
    # Find out size of each dimension of this NetCDF matrix
    my ($name, $size, @cnt);
    for ($i=0;$i<$ndims;$i++) {
      my $rc = PDL::NetCDF::nc_inq_dim ($self->{NCID}, $dimids->at($i), $name='x' x NC_MAX_NAME(), $size=-999);
      barf ("get:  Cannot get info on this dimension -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
      push (@cnt, $size);
    }

    # Create empty PDL (of correct type and size) to hold output from NetCDF file
    $pdl = &{$typemap{$self->{DATATYPES}{$varnm}}}(reverse @cnt);	

    # Get the data
    if (ref($pdl) =~ /Char/) {  # a PDL::Char type PDL--write a netcdf char variable
      my $f = ${$pdl->get_dataref}; 
      $rc = PDL::NetCDF::nc_get_var_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $f);
      ${$pdl->get_dataref} = $f;	
      $pdl->upd_data();
    } else {
      $rc = &{$typemap4{$pdl->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, $pdl);
    }
    barf ("get:  Cannot get data -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  }
  
  return $pdl;
}


# Get the size of a dimension
sub dimsize {
  my $self  = shift;
  my $dimnm = shift;
  
  barf ("dimsize: No such dimension -- $dimnm") unless exists ($self->{DIMIDS}{$dimnm});

  my ($dimsz, $name);
  my $rc = nc_inq_dimlen ($self->{NCID}, $self->{DIMIDS}{$dimnm}, $dimsz=-999);
  barf ("dimsize:  Cannot get dimension length -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  return $dimsz;
}



# Put a netCDF attribute from a PDL or string
sub putatt {
  my $self  = shift;  # name of object
  my $att   = shift;  # Attribute to put.  Can be a string or a PDL
  my $attnm = shift;  # Name of attribute to put
  my $varnm = shift;  # name of netCDF variable this attribute is to be associated with
                      # (defaults to global if not passed).

  barf "Cannot write read-only netCDF file $self->{FILENM}" if ($self->{WR} eq 'r');

  # If no varnm passed in, fetch a global attribute
  if (!defined($varnm)) { 
    $varnm = 'GLOBAL';
    $self->{VARIDS}{$varnm} = NC_GLOBAL();
  } 

  # Put netCDF file into define mode
  unless ($self->{DEFINE}) {
    my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
    barf ("putatt:  Cannot put file into define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    $self->{DEFINE} = 1;
  }

  # Attribute is a PDL one-D variable
  if (ref $att eq 'PDL') {

    barf ("Attributes can only be 1 dimensional") if ($att->dims != 1);

    # Make PDL physical
    $att->make_physical;

    # Put the attribute
    my $rc = &{$typemap5{$att->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, 
					      $attnm, $typemap3{$att->get_datatype},
					      nelem ($att), $att);
    barf ("putatt:  Cannot put PDL attribute -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  
  
#
#  update self 
#

    $self->{ATTTYPE}{$varnm}{$attnm} = $typemap3{$att->get_datatype};
    $self->{ATTLEN}{$varnm}{$attnm} = $att->nelem;

  } elsif (ref $att eq '') {  # A scalar variable

    # Put the attribute
    my $rc = PDL::NetCDF::nc_put_att_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm,
			      length($att), $att."\0"); # null terminate!
    barf ("putatt:  Cannot put string attribute -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

#
#  update self 
#

    $self->{ATTTYPE}{$varnm}{$attnm} = NC_CHAR();
    $self->{ATTLEN}{$varnm}{$attnm} = length($att);

  } else {

    barf ("Attributes of this type not supported");

  }

  # Get out of define mode
  if ($self->{DEFINE}) {
    my $rc = PDL::NetCDF::nc_enddef ($self->{NCID});
    barf ("put:  Cannot end define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    $self->{DEFINE} = 0;
  }

  $rc = PDL::NetCDF::nc_sync($self->{NCID});
  barf ("putatt:  Cannot sync file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

  return 0;

}


# Get an attribute value into a pdl
sub getatt {
  my $self  = shift;
  my $attnm = shift;
  my $varnm = shift;
  
  # If no varnm passed in, fetch a global attribute
  if (!defined($varnm)) { 
    $varnm = 'GLOBAL';
    $self->{VARIDS}{$varnm} = NC_GLOBAL();
  } 

  # Determine the type and length of this attribute
  my($datatype,$attlen);
  if(defined $self->{ATTTYPE}{$varnm}{$attnm}){
     $datatype = $self->{ATTTYPE}{$varnm}{$attnm};
     $attlen = $self->{ATTLEN}{$varnm}{$attnm};
  }else{
     barf ("getatt:  Attribute not found -- $varnm:$attnm");
  } 
#  $rc = PDL::NetCDF::nc_inq_atttype ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, my $datatype=-999);
#  barf ("getatt:  Cannot get attribute type -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  
#
#  $rc = PDL::NetCDF::nc_inq_attlen ($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, my $attlen=-999);
#  barf ("getatt:  Cannot get attribute length -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

  # Get text attribute into perl string
  if ($datatype == NC_CHAR()) {

    $rc = PDL::NetCDF::nc_get_att_text ($self->{NCID}, $self->{VARIDS}{$varnm}, 
			   $attnm, my $str=('x' x $attlen)."\0"); # null terminate!
    barf ("getatt:  Cannot get text attribute -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

    return $str;

  } 

  # Get PDL attribute

  # Create empty PDL (of correct type and size) to hold output from NetCDF file
  my $pdl = &{$typemap{$datatype}}($attlen);	

  # Get the attribute
  $rc = &{$typemap6{$pdl->get_datatype}}($self->{NCID}, $self->{VARIDS}{$varnm}, $attnm, $pdl);
  barf ("getatt:  Cannot get attribute -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  return $pdl;

}


# Put a perl string into a multi-dimensional netCDF object
#
## ex:  $o->puttext ('station_names', ['n_stations', 'n_string'], [3,10], 'Station1  Station2  Station3');
# 
sub puttext {
  my $self    = shift;
  my $varnm   = shift;
  my $dims    = shift;
  my $dimlens = shift;  # Length of dimensions
  my $str     = shift;  # Perl string with data
  
  my $ndims = scalar(@$dimlens);

  barf "Cannot write read-only netCDF file $self->{FILENM}" if ($self->{WR} eq 'r');

  # Define dimensions if necessary

  my $dimids = zeroes (PDL::long, $ndims);
  for (my $i=0;$i<@$dims;$i++) {
    if (!defined($self->{DIMIDS}{$$dims[$i]})) {

      unless ($self->{DEFINE}) {
	my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
	barf ("Cannot put file into define mode") if $rc;
	$self->{DEFINE} = 1;
      }

      my $rc = PDL::NetCDF::nc_def_dim ($self->{NCID}, $$dims[$i], $$dimlens[$i], 
				$self->{DIMIDS}{$$dims[$i]}=-999);
      barf ("put:  Cannot define dimension -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;

      $self->{DIMLENS}{$$dims[$i]} = $$dimlens[$i];

    }
    set ($dimids, $i, $self->{DIMIDS}{$$dims[$i]});

    barf ("put:  Attempt to redefine length of dimension $$dims[$i]") 
      if ($self->{DIMLENS}{$$dims[$i]} != $$dimlens[$i]);
    
  }

  # Define variable if necessary
  if (!defined($self->{VARIDS}{$varnm})) {
  
    unless ($self->{DEFINE}) {
      my $rc = PDL::NetCDF::nc_redef ($self->{NCID});
      barf ("put:  Cannot put file into define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;
      $self->{DEFINE} = 1;
    }

    my $datatype =  NC_CHAR();
    my $rc = PDL::NetCDF::nc_def_var ($self->{NCID}, $varnm, $datatype, 
			   $ndims, $dimids, $self->{VARIDS}{$varnm}=-999);
    barf ("put:  Cannot define variable -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

    $self->{DATATYPES}{$varnm} = $datatype;

  }

  # Get out of define mode
  if ($self->{DEFINE}) {
    my $rc = PDL::NetCDF::nc_enddef ($self->{NCID});
    barf ("put:  Cannot end define mode -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
    $self->{DEFINE} = 0;
  }





    my $st = pack ("L*", ((0) x $ndims));
    my $ct = pack ("L*", @$dimlens);




  # Call the 'put' routine 
  $rc = PDL::NetCDF::nc_put_vara_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, $str."\0"); # null terminate!
  barf ("put:  Cannot write file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  $rc = PDL::NetCDF::nc_sync($self->{NCID});
  barf ("put:  Cannot sync file -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    

  return 0;
}



# Get an entire text variable into one big string.  Multiple dimensions are concatenated.
sub gettext {
  my $self  = shift;
  my $varnm = shift;
  
  # Determine the type of this variable
  my ($ndims, $natts, $i, $rc);
  $rc = PDL::NetCDF::nc_inq_varndims ($self->{NCID}, $self->{VARIDS}{$varnm}, $ndims=-999);
  my $dimids = zeroes (PDL::long, $ndims);
  $rc |= PDL::NetCDF::nc_inq_vardimid ($self->{NCID}, $self->{VARIDS}{$varnm}, $dimids);
  barf ("get:  Cannot get info on this var id -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
  
  # Find out size of each dimension of this NetCDF matrix
  my ($name, $size, $total_size, @dims);
  $total_size = 1;
  @dims = ();
  for ($i=0;$i<$ndims;$i++) {
      my $rc = PDL::NetCDF::nc_inq_dim ($self->{NCID}, $dimids->at($i), $name='x' x NC_MAX_NAME(), $size=-999);
      barf ("get:  Cannot get info on this dimension -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;    
      $total_size *= $size;
      push (@dims, $size);
  }

  my $datatype = $self->{DATATYPES}{$varnm};

  # Get text attribute into perl string
  barf ("gettext:  Data not of string type") if ($datatype != NC_CHAR());





    my $st = pack ("L*", ((0) x $ndims));
    my $ct = pack ("L*", @dims);




  $rc = PDL::NetCDF::nc_get_vara_text ($self->{NCID}, $self->{VARIDS}{$varnm}, $st, $ct, my $str=('x' x $total_size)."\0"); # null terminate!
  barf ("gettext:  Cannot get text variable -- " . PDL::NetCDF::nc_strerror ($rc)) if $rc;  

  return $str;

}





# These defines are taken from netcdf.h  I deemed this cleaner than using
# h2xs and the autoload stuff, which mixes alkwardly with PP.
sub NC_FILL_BYTE { return -127; }
sub NC_FILL_CHAR { return 0; }
sub NC_FILL_SHORT { return -32767; }
sub NC_FILL_INT { return -2147483647; }
sub NC_FILL_FLOAT { return 9.9692099683868690e+36; } # near 15 * 2^119 
sub NC_FILL_DOUBLE { return 9.9692099683868690e+36; }

sub NC_CLOBBER { return 0; }
sub NC_NOWRITE { return 0; }
sub NC_WRITE { return 0x1; } # read & write 
sub NC_NOCLOBBER { return 0x4; } # Don't destroy existing file on create 
sub NC_FILL { return 0; }	 # argument to ncsetfill to clear NC_NOFILL 
sub NC_NOFILL { return 0x100; }  # Don't fill data section an records 
sub NC_LOCK { return 0x0400; }   # Use locking if available 
sub NC_SHARE { return 0x0800; }  # Share updates, limit cacheing 
sub NC_UNLIMITED {  return 0; }
sub NC_GLOBAL { return -1; }

sub NC_MAX_DIMS { return 100; }  # max dimensions per file 
sub NC_MAX_ATTRS { return 2000; }# max global or per variable attributes 
sub NC_MAX_VARS { return 2000; } # max variables per file 
sub NC_MAX_NAME { return 128; }	 # max length of a name 
sub NC_MAX_VAR_DIMS { return NC_MAX_DIMS; } # max per variable dimensions

sub NC_NOERR { return 0; }       # No Error 
sub NC_EBADID { return -33; }    # Not a netcdf id 
sub NC_ENFILE { return -34; }    # Too many netcdfs open 
sub NC_EEXIST { return -35; }    # netcdf file exists && NC_NOCLOBBER 
sub NC_EINVAL { return -36; }    # Invalid Argument 
sub NC_EPERM  { return -37; }    # Write to read only 
sub NC_ENOTINDEFINE { return -38; } # Operation not allowed in data mode 
sub NC_EINDEFINE { return -39; } # Operation not allowed in define mode 
sub NC_EINVALCOORDS { return -40; } # Index exceeds dimension bound 
sub NC_EMAXDIMS { return -41; }  # NC_MAX_DIMS exceeded 
sub NC_ENAMEINUSE { return -42; }# String match to name in use 
sub NC_ENOTATT { return -43; }   # Attribute not found 
sub NC_EMAXATTS { return -44; }  # NC_MAX_ATTRS exceeded 
sub NC_EBADTYPE { return -45; }  # Not a netcdf data type 
sub NC_EBADDIM { return -46; }   # Invalid dimension id or name 
sub NC_EUNLIMPOS { return -47; } # NC_UNLIMITED in the wrong index 
sub NC_EMAXVARS { return -48; }	 # NC_MAX_VARS exceeded 
sub NC_ENOTVAR { return -49; }	 # Variable not found 
sub NC_EGLOBAL { return -50; }	 # Action prohibited on NC_GLOBAL varid 
sub NC_ENOTNC { return -51; }	 # Not a netcdf file 
sub NC_ESTS   { return -52; }	 # In Fortran, string too short 
sub NC_EMAXNAME { return -53; }	 # NC_MAX_NAME exceeded 
sub NC_EUNLIMIT { return -54; }	 # NC_UNLIMITED size already in use 
sub NC_ENORECVARS { return -55; }# nc_rec op when there are no record vars 
sub NC_ECHAR { return -56; }	 # Attempt to convert between text & numbers 
sub NC_EEDGE { return -57; }	 # Edge+start exceeds dimension bound 
sub NC_ESTRIDE { return -58; }	 # Illegal stride 
sub NC_EBADNAME { return -59; }	 # Attribute or variable name
sub NC_ERANGE { return -60; }	 # Math result not representable 
sub NC_ENOMEM { return -61; }	 # Memory allocation (malloc) failure 
sub NC_SYSERR { return (-31)};

sub NC_FATAL { return 1};        # quit on netcdf error
sub NC_VERBOSE { return 2};      # give verbose error messages

sub NC_BYTE { return 1; }        # signed 1 byte integer 
sub NC_CHAR { return 2; }        # ISO/ASCII character 
sub NC_SHORT { return 3; }	 # signed 2 byte integer 
sub NC_INT { return 4; }	 # signed 4 byte integer 
sub NC_FLOAT { return 5; }       # single precision floating point number 
sub NC_DOUBLE { return 6; }	 # double precision floating point number 


;



# Exit with OK status

1;

		   