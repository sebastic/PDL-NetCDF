# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use PDL;
use PDL::NetCDF;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

#
## Test object-oriented interface
#

# Test starting with new file
$obj = PDL::NetCDF->new ('foo.nc');
$in1 = pdl [[1,2,3], [4,5,6]];
$obj->put ('var1', ['dim1', 'dim2'], $in1);
$out1 = $obj->get ('var1');

$ok = ($in1 == $out1)->sum == $in1->nelem;
print( ($ok ? "ok ": "not ok "), "2\n" ); 

$dims  = pdl $in1->dims;
$dims1 = pdl $out1->dims;
$ok = ($dims == $dims1)->sum == $dims->nelem;
print( ($ok ? "ok ": "not ok "), "3\n" ); 

$in2 = pdl [[1,2,3,4], [5,6,7,8]]; # dim1 is already 3, not 4
eval { $obj->put ('var2', ['dim1', 'dim2'], $in2); }; # Dimension error
$ok = ($@ =~ /Attempt to redefine length of dimension/);
print( ($ok ? "ok ": "not ok "), "4\n" ); 

$ok = !$obj->close;
print( ($ok ? "ok ": "not ok "), "5\n" ); 

# Try again with existing file
$obj1 = PDL::NetCDF->new ('>foo.nc');
$pdl = pdl [[1,2,3], [4,5,6]];
$obj1->put ('var1', ['dim1', 'dim2'], $pdl);
$pdl1 = $obj1->get ('var1');

$ok = ($pdl1 == $pdl)->sum == $pdl->nelem;
print( ($ok ? "ok ": "not ok "), "6\n" ); 

$dims  = pdl $pdl->dims;
$dims1 = pdl $pdl1->dims;
$ok = ($dims == $dims1)->sum == $dims->nelem;
print( ($ok ? "ok ": "not ok "), "7\n" ); 

$attin = pdl [1,2,3];
$rc = $obj1->putatt ($attin, 'double_attribute', 'var1');
print( ($rc ? "not ok ": "ok "), "8\n" ); 

$attout = $obj1->getatt ('double_attribute', 'var1');
$ok = ($attin == $attout)->sum == $attin->nelem;
print( ($ok ? "ok ": "not ok "), "9\n" ); 

$rc = $obj1->putatt ('Text Attribute', 'text_attribute');
print( ($rc ? "not ok ": "ok "), "10\n" ); 

$attout = $obj1->getatt ('text_attribute');
print( ($attout eq 'Text Attribute' ? "ok ": "not ok "), "11\n" ); 

# Get slices
$out2 = $obj->get ('var1', [1,1], [1,1]);
$ok = ($out2 == pdl[5])->sum == $out2->nelem;
print( ($ok ? "ok ": "not ok "), "12\n" ); 

$out2 = $obj->get ('var1', [0,1], [2,1]);
$ok = ($out2 == pdl[2,5])->sum == $out2->nelem;
print( ($ok ? "ok ": "not ok "), "13\n" ); 

$out2 = $obj->get ('var1', [0,1], [1,1]);
$ok = ($out2 == pdl[2])->sum == $out2->nelem;
print( ($ok ? "ok ": "not ok "), "14\n" ); 

# Test with a bogus file
open (IN, ">bogus.nc");
print IN "I'm not a netCDF file\n";
close IN;
eval { $obj2 = PDL::NetCDF->new ('bogus.nc'); };
$ok = ($@ =~ /Not a netCDF file/);
print( ($ok ? "ok ": "not ok "), "15\n" ); 

END {
  print "Removing test files, foo.nc, bogus.nc\n";
  unlink "foo.nc"; 
  unlink "bogus.nc"; 
}

