# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..63\n"; }
END {print "not ok 1\n" unless $loaded;}
use PDL;
use PDL::OO;
use PDL::NetCDF;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

#
# Create netCDF file.
#
$ncid = nccreate('foo.nc', NC_CLOBBER);
print( (($ncid >= 0) ? "ok ": "not ok "), "2\n" );

#
# Set fill mode.
#
$rc = ncsetfill($ncid, NC_NOFILL);
print( (($rc == 0) ? "ok ": "not ok "), "3\n" );

#
# Define fixed dimensions.
#
$dim0id = ncdimdef($ncid, 'dim0', 2);
print( (($dim0id >= 0) ? "ok ": "not ok "), "4\n" );

$dim1id = ncdimdef($ncid, 'dim1', 3);
print( (($dim1id >= 0) ? "ok ": "not ok "), "5\n" );

$dimstrid = ncdimdef($ncid, 'strlen', 12);
print( (($dimstrid >= 0) ? "ok ": "not ok "), "6\n" );

#
# Define fixed variables.
#
$fixvarid = ncvardef($ncid, 'fixvar', NC_FLOAT, [$dim0id, $dim1id]);
print( (($fixvarid >= 0) ? "ok ": "not ok "), "7\n" );

#
# Put global attribute.
#
$histatt = "Created by $0 on " . localtime();
$attid = ncattput($ncid, NC_GLOBAL, 'history', NC_CHAR, $histatt);
print( (($attid != -1) ? "ok ": "not ok "), "8\n" );

#
# Put variable attributes.
#
$attid = ncattput($ncid, $fixvarid, "att_byte", NC_BYTE, [255, -128]);
print( (($attid >= 0) ? "ok ": "not ok "), "9\n" );

$attid = ncattput($ncid, $fixvarid, "att_char", NC_CHAR, "string");
print( (($attid >= 0) ? "ok ": "not ok "), "10\n" );

$attid = ncattput($ncid, $fixvarid, "att_short", NC_SHORT, [5, 6, 7]);
print( (($attid >= 0) ? "ok ": "not ok "), "11\n" );

$attid = ncattput($ncid, $fixvarid, "att_long", NC_LONG, [3,4]);
print( (($attid >= 0) ? "ok ": "not ok "), "12\n" );

$attid = ncattput($ncid, $fixvarid, "att_float", NC_FLOAT, 2.7182818);
print( (($attid >= 0) ? "ok ": "not ok "), "13\n" );

$att_double = [2.7182818, 3.1415927];
$attid = ncattput($ncid, $fixvarid, "att_double", NC_DOUBLE, $att_double);
print( (($attid >= 0) ? "ok ": "not ok "), "14\n" );

#
# Define record dimension.
#
$recdimid = ncdimdef($ncid, "recdim", NC_UNLIMITED);
print( (($recdimid >= 0) ? "ok ": "not ok "), "15\n" );

#
# Define record variables.
#
$recvar0id = ncvardef($ncid, "recvar0", NC_SHORT, [$recdimid, $dim0id]);
print( (($recvar0id >= 0) ? "ok ": "not ok "), "16\n" );

$recvar1id = ncvardef($ncid, "recvar1", NC_FLOAT, [$recdimid, $dim1id]);
print( (($recvar1id >= 0) ? "ok ": "not ok "), "17\n" );

$recvarstrid = ncvardef($ncid, "recvarstr", NC_CHAR, [$recdimid, $dimstrid]);
print( (($recvarstrid >= 0) ? "ok ": "not ok "), "18\n" );

#
# End definition.
#
$status = ncendef($ncid);
print( (($status >= 0) ? "ok ": "not ok "), "19\n" );

#
# Write values to fixed variable.
#
$invar = PDL::Core::float [998, 999];
$status = ncvarput($ncid, $fixvarid, [0,1], [2,1], $invar);
print( (($status >= 0) ? "ok ": "not ok "), "20\n" );

#
# Synchronize netCDF file.
#
$status = ncsync($ncid);
print( (($status >= 0) ? "ok ": "not ok "), "21\n" );

#
# Write values to record variables.
#
@recvar0 = (101 .. 102);
@recvar1 = (201 .. 203);
$status = ncrecput($ncid, 0, [\@recvar0, \@recvar1, ["hello world\0"]]);
print( (($status >= 0) ? "ok ": "not ok "), "22\n" );

#
# Save the values of the record variables.
#
$recvars = [ \@recvar0, \@recvar1 ];

#
# Close netCDF file.
#
$status = ncclose($ncid);
print( (($status >= 0) ? "ok ": "not ok "), "23\n" );

#
# Open netCDF file.
#
$ncid = ncopen('foo.nc', NC_RDWR);
print( (($ncid >= 0) ? "ok ": "not ok "), "24\n" );

#
# Inquire about netCDF file.
#
$status = ncinquire($ncid, $nd, $nv, $na, $dimid);
print( (($status >= 0) ? "ok ": "not ok "), "25\n" );

$ok = ($nd == 4) && ($nv == 4) && ($na == 1) && ($dimid == 3);
print( ($ok ? "ok ": "not ok "), "26\n" );

#
# Get global attribute.
#
$rc = ncattname($ncid, NC_GLOBAL, 0, $name);
print( (($rc == 0) ? "ok ": "not ok "), "27\n" );
print( (($name eq 'history') ? "ok ": "not ok "), "28\n" );

$attval = "";
$rc = ncattget($ncid, NC_GLOBAL, "history", \$attval);
print( (($rc == 0) ? "ok ": "not ok "), "29\n" );
print( (($attval =~ /$histatt/) ? "ok ": "not ok "), "30\n" );

#
# Get ID of second dimension.
#
$dimid = ncdimid($ncid, 'dim1');
print( (($dimid == $dim1id) ? "ok ": "not ok "), "31\n" );

#
# Get second dimension information.
#
$rc = ncdiminq($ncid, $dim1id, $name, $length);
print( (($rc == 0) ? "ok ": "not ok "), "32\n" );
print( (($name eq 'dim1') ? "ok ": "not ok "), "33\n" );
print( (($length == 3) ? "ok ": "not ok "), "34\n" );

#
# Get variable ID of fixed variable.
#
$varid = ncvarid($ncid, 'fixvar');
print( (($varid >= 0) ? "ok ": "not ok "), "35\n" ); 
print( (($varid == $fixvarid) ? "ok ": "not ok "), "36\n" ); 

#
# Get information on fixed variable.
#
@dimids = ();
$rc = ncvarinq($ncid, $fixvarid, $name, $type, $ndims, \@dimids, $natts);
print( (($rc == 0) ? "ok ": "not ok "), "37\n" ); 
$ok = ($name eq 'fixvar' && $type == NC_FLOAT && $ndims == 2 && $natts == 6);
print( ($ok ? "ok ": "not ok "), "38\n" ); 

#
# Get last value of first record variable.
#
@coords = (0, $#recvar0);
$rc = ncvarget1($ncid, $recvar0id, \@coords, $value);
print( (($rc == 0) ? "ok ": "not ok "), "39\n" ); 
print( (($value == $recvar0[$#recvar0]) ? "ok ": "not ok "), "40\n" ); 

#
# Get fixed variable values.
#
$values = ncvarget($ncid, $varid, [0,1], [2,1]);
$cmp = float [998, 999];
$ok = ($cmp == $values)->sum == $cmp->nelem;
print( ($ok ? "ok ": "not ok "), "41\n" ); 

#
# Get fixed variable attributes.
#
$rc = ncattname($ncid, $fixvarid, 0, $name);
print( (($rc == 0) ? "ok ": "not ok "), "42\n" ); 
print( (($name eq "att_byte") ? "ok ": "not ok "), "43\n" ); 

$rc = ncattinq($ncid, $fixvarid, "att_float", $type, $len);
print( (($rc == 0) ? "ok ": "not ok "), "44\n" ); 
print( (($type == NC_FLOAT) ? "ok ": "not ok "), "45\n" ); 
print( (($len == 1) ? "ok ": "not ok "), "46\n" ); 

@values = ();
$rc = ncattget($ncid, $fixvarid, "att_float", \@values);
print( (($rc == 0) ? "ok ": "not ok "), "47\n" ); 
print( ((abs(($values[0] - 2.7182818) / 2.7182818) < .000001) ? "ok ": "not ok "), "48\n" ); 

#
# Get nctypelen().
#
$len = nctypelen(NC_FLOAT);
print( (($len == 4) ? "ok ": "not ok "), "49\n" ); 

#
# Inquire about record variables.
#
@recvarids = ();
@recsizes = ();
$rc = ncrecinq($ncid, $nrecvars, \@recvarids, \@recsizes);
print( (($rc == 0) ? "ok ": "not ok "), "50\n" ); 
print( (($nrecvars == 3) ? "ok ": "not ok "), "51\n" ); 
print( (($recvarids[0] == $recvar0id && $recvarids[1] == $recvar1id) ? "ok ": "not ok "), "52\n" ); 
$ok = ($recsizes[0] == 2 * nctypelen(NC_SHORT)) &&
  ($recsizes[1] == 3 * nctypelen(NC_FLOAT));
print( (($ok) ? "ok ": "not ok "), "53\n" ); 

#
# Read values of record variables.
#
@record = ();
$rc = ncrecget($ncid, 0, \@record);
print( (($rc >= 0) ? "ok ": "not ok "), "54\n" ); 
print( ((@record == 3) ? "ok ": "not ok "), "55\n" ); 

$ok = 1;
@dimlen = (2, 3);
for ($i = 0; $i < 2; $i++) {
    $varref = $record[$i];
    if (@$varref != $dimlen[$i]) { $ok = 0; }
    for ($j = 0; $j < $dimlen[$i]; $j++) {
      if ($$varref[$j] != $$recvars[$i][$j]) { $ok = 0; }
    }
}
print( (($ok) ? "ok ": "not ok "), "56\n" ); 
print( ((${$record[2]} =~ /hello world/) ? "ok ": "not ok "), "57\n" ); 

#
# Get Entire fixed variable (do not specify start and count);
#
$values = ncvarget($ncid, $varid);
$cmp = float [[0, 998, 0], [0, 999, 0]];
$ok = ($cmp == $values)->sum == $cmp->nelem;
print( ($ok ? "ok ": "not ok "), "58\n" ); 

$rc = ncclose($ncid);
print( (($rc == 0) ? "ok ": "not ok "), "59\n" ); 

#
## Test object-oriented variable and attribute fetching
#
$obj = PDL::NetCDF->new ('foo.nc');

$var = $obj->get('fixvar');
$cmp = float [[0, 998, 0], [0, 999, 0]];
$ok = ($cmp == $values)->sum == $cmp->nelem;
print( ($ok ? "ok ": "not ok "), "60\n" ); 

$var = $obj->get('fixvar', [0,1], [2,1]);
$cmp = float [998, 999];
$ok = ($cmp == $var)->sum == $cmp->nelem;
print( ($ok ? "ok ": "not ok "), "61\n" ); 

$att = $obj->getatt('history');
print( (($att =~ /$histatt/) ? "ok ": "not ok "), "62\n" );

$att = $obj->getatt('att_double', 'fixvar');
$cmp = double $att_double;
$ok = ($cmp == $att)->sum == $cmp->nelem;
print( ($ok ? "ok ": "not ok "), "63\n" );

print "Removing test file, foo.nc\n";
unlink "foo.nc";

