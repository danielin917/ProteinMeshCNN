#!/usr/bin/perl

###
### pdb2wrl.pl [options] < in.pdb > out.wrl
### 
### This perl filter converts a pdb-format protein 
### coordinate file (in.pdb) to a VRML-format file (out.wrl), which is 
### viewable by a variety of viewers including SGI's webspace.
###
### The default output format is thick tubes connecting CA atoms. 
###
### options:
### 
###   -LinesSeq     CAs sequentially connected by thin lines  (fastest display)
###   -LinesDist    CAs connected by thin lines based on distance (fastest display)
###   -thresh t     gives the threshold value t for -LinesDist
###   -thick t      gives the thickness of the tubes 
###   -simple       substitutes prisms for the tubes (faster display)
###
### This work is part of the Protein Motions Database project. 
### The database attempts to list all examples of protein motions 
### and includes movies and graphics illustrating selected motions.
###
### The motions database is at http://hyper.stanford.edu/~mbg/ProtMotDB
###
### The current citation for the database is :
### M Gerstein, A M Lesk & C Chothia (1994). 
### "Structural Mechanisms for Domain Movements," Biochemistry 33: 6739-6749. 
###
### This script is Copyright 1995 
###
### Permission is granted to use and modify this library so long as the
### copyright above is maintained, modifications are documented, and
### credit is given for any use. That is, please cite the above reference 
### if you use this script. 
###
### Above copyright statement modified from Steven Brenner's cgi-lib.pl !!
### Some of the cylinder code adapted from David Hinds .
###
### Mark Gerstein <mbg@hyper.stanford.edu>
###

###############################################################################


&hello ;

print STDERR "pdb2wrl.pl: Part of Protein Motions Database\n" ;
print STDERR "pdb2wrl.pl: See http://hyper.stanford.edu/~mbg/ProtMotDB\n"; 

$lk = "[" ;
$rk = "]" ;
$lb = "{" ;
$rb = "}" ;

&ReadCoords ; # into global arrays @xx, @yy, @zz, @resns

if (&Option("LinesSeq")) {
    &DumpLinesSeq ;
} elsif (&Option("LinesDist")) {
    &DumpLinesDist ;
} else {
    &DumpCylSeq ;
}

###############################################################################

sub ReadCoords { 
    local($npt);
    while (<STDIN>) {
	if (/^ATOM/ && / CA /) {
	    local($iser,$atnam,$resnam, $chnnam,$resn,$x,$y,$z,$occ,$b,$segid) = 
		&ParsePDBAtom($_);  
	    $xx[$npt] = $x ;
	    $yy[$npt] = $y ;
	    $zz[$npt] = $z ;
	    $resns[$npt] = $resn ;
	    $npt++;
	}
    }
}

sub DumpLinesSeq {
    local($reso) = -9999; 
    local($npt) = $#xx ;
    local($i,$x,$y,$z,@line);
    &Prolog ;
    print "Coordinate3 $lb point $lk\n" ;
    for ($i=0; $i<$npt; $i++) {
	$x = $xx[$i]; $y = $yy[$i] ; $z = $zz[$i] ;
	print "$x $y $z,\n" ;
	if ($resns[$i] - 1 == $reso) {
	    $line[$nlin] = $i-1 .", $i" ;
	    $nlin++ ;
	}
	$reso = $resns[$i];
    }
    print "$rk $rb IndexedLineSet $lb coordIndex $lk\n" ;
	
    for($j=0; $j<$nlin; $j++) {
	print "$line[$j], -1,\n" ;
    }

    print "$rk $rb " ;
    print "$rb\n" ;
}

sub DumpLinesDist {
    local($thresh) = &StringAfterOption("thresh",6); 
    local($thresh2) = $thresh * $thresh;  
    local($npt) = $#xx ;
    &Prolog ;
    local($i,$x,$y,$z,$xo,$yo,$zo,$dx2,$dy2,$dz2);
    $zo = $yo = $xo = -99999 ;
    print "Coordinate3 $lb point $lk\n" ;
    for ($i=0; $i<$npt; $i++) {
	$x = $xx[$i]; $y = $yy[$i] ; $z = $zz[$i] ;
	print "$x $y $z,\n" ;
	$dx2 = &sq($x - $xo) ;
	$dy2 = &sq($y - $yo) ;
	$dz2 = &sq($z - $zo) ;
	if ($dx2 + $dy2 + $dz2 < $thresh2) {
	    $line[$nlin] = $i-1 .", $i" ;
	    $nlin++ ;
	}
	$xo = $x ; $yo = $y ; $zo = $z ;
    }
    print "$rk $rb IndexedLineSet $lb coordIndex $lk\n" ;
	
    for($j=0; $j<$nlin; $j++) {
	print "$line[$j], -1,\n" ;
    }

    print "$rk $rb " ;
    print "$rb\n" ;
}

sub DumpCylSeq {
    local($i,$x,$y,$z,$xl,$yl,$zl);
    local($npt) = $#xx ;
    $simple = &Option("simple") ;
    $thick  = &StringAfterOption("thick",1.5);  # controls thickness of cylinders 

    print "#VRML V1.0 ascii\n" ;
    print "Separator $lb\n";

    &prolog2 ;
    for ($i=0; $i<$npt; $i++) {
	$x = $xx[$i]; $y = $yy[$i] ; $z = $zz[$i] ;
	printf("Separator $lb\n");
	&DrawSphere($x,$y,$z,$thick);
	print "$rb\n" ;
    }
    print "$rb\n" ;

    &prolog2 ;

    for ($i=1; $i<$npt; $i++) {
	$x = $xx[$i]; $y = $yy[$i] ; $z = $zz[$i] ;
	$xl = $xx[$i-1]; $yl = $yy[$i-1] ; $zl = $zz[$i-1] ;
	printf("Separator $lb\n");
	&DrawCyl($x,$y,$z,$xl,$yl,$zl,$thick);
	print "$rb\n" ;
    }

    print "$rb\n" ;
    print "$rb\n" ;
}

sub Prolog {

    print <<EOF;
#VRML V1.0 ascii
Separator $lb
DirectionalLight { direction 1 11 -1 }
Material { diffuseColor 0 1 0 }  # 
EOF
    
}

sub sq {
    local($a) = @_ ;
    return $a * $a ;
}

sub prolog2 {
        print <<EOF;
 Separator $lb
        Material $lb
            ambientColor        0 0.0714286 0.0652005
            diffuseColor        0 0.286882 0.261868
            specularColor       0.243549 0.556863 0.607143
            emissiveColor       0 0 0
            shininess   0.0663265
            transparency        0
        $rb
EOF
}


###############################################################################
# Adapted from David Hinds' chain.c program  <dhinds@allegro.stanford.edu>    #
###############################################################################

sub DrawSphere {
    local($x,$y,$z,$r) = @_;
    printf("Transform {\n");
    printf(" translation %.2f %.2f %.2f\n", $x, $y, $z);
    printf(" scaleFactor %.2f %.2f %.2f\n", $r, $r, $r);
    printf(" }\n");
    printf("%s { }\n", $simple ? "Cube" : "Sphere");
}
  
sub DrawCyl {
    local($ax,$ay,$az,$bx,$by,$bz,$w) = @_ ;
    local($dx,$dy,$dz,$cx,$cy,$l);
    $cx = ($ax+$bx)/2; $dx = $ax - $bx;
    $cy = ($ay+$by)/2; $dy = $ay - $by;
    $cz = ($az+$bz)/2; $dz = $az - $bz;
    $l = sqrt(&sq($dx) + &sq($dy) + &sq($dz));
    printf("Transform {\n");
    printf(" translation %.2f %.2f %.2f\n", $cx, $cy, $cz);
    printf(" scaleFactor %.2f %.2f %.2f\n", $w, $l/2.0, $w);
    printf(" rotation %.3f 0.0 %.3f %.3f\n", -$dz, $dx,
	   - atan2(sqrt(&sq($dx)+&sq($dz)),($dy)) );
    printf(" }\n");
    printf("%s { }\n", $simple ? "Cube" : "Cylinder");
}
  
###############################################################################
#			   Library routines                                   #
###############################################################################

sub ParsePDBAtom {
    local($_) = @_ ;
    # local($save) = $[ ; $[ = 1;
    local($iser)   = substr($_, 7,5);  
    local($atnam)  = substr($_,12,4);  
    local($resnam) = substr($_,17,4);  
    local($chnnam) = substr($_,21,1);  
    local($iresn)   = substr($_,22,4); 
    local($x)      = substr($_,30,8);  
    local($y)      = substr($_,38,8);  
    local($z)      = substr($_,46,8);  
    local($occ)    = substr($_,56,6);  
    local($b)      = substr($_,60,6);  
    local($segid)  = substr($_,67,10);  
    # $[ = $save;
    local(@list) = ($iser,$atnam,$resnam,
	   $chnnam,$iresn,$x,$y,$z,$occ,$b,$segid);
    foreach (@list) {
	s/ +//g ;
    }
    # $" = ':' ; print "@list\n" ;
    return(@list)
}
    
sub WritePDBAtom {                               
    local($PDBFMT) =            
        "ATOM  %5d %4s %-4s%1s%4d    %8.3f%8.3f%8.3f%6.2f%6.2f %9s\n"; # 
    local($stream,$iser,$atnam,$resnam,
          $chnnam,$iresn,$x,$y,$z,$occ,$b,$segid) = @_ ;
    printf($stream $PDBFMT,$iser,$atnam,$resnam,$chnnam,
            $iresn,$x,$y,$z,$occ,$b,
            $segid);
  
}

###############################################################################

sub  StringAfterOption {
    local($Option, $TheDefault) = @_;
    local($r) = &ReturnArgvMatch($Option, @ARGV);
    if ($r ne "ReturnArgvMatch-finds-nothing") {
	printf(STDERR "[New String    ] -%s = %s\n",$Option,$r);
	return $r;
    } else {
	printf(STDERR "[Default String] -%s = %s\n",$Option,$TheDefault);
	return $TheDefault;
    }
}

sub ReturnArgvMatch {
    local($Option,@argv) = @_ ;
    local($r) = 0;
    local($i);
    local($b) = "-" . $Option ;
    for ($i=0; $i <= ($#argv - 1) ; $i++) {
	if ($argv[$i] eq $b) {
	    $r = $i + 1;
	}
    }
    return ($r ? $argv[$r] : "ReturnArgvMatch-finds-nothing" );
}

sub Option {
    local($Option) = @_;
    &ArgvMatch($Option,@ARGV);
}

sub ArgvMatch {
    local($Option,@argv) = @_;
    local($r)=0;
    local($i);
    local($b) = "-" . $Option;
    for ($i=0; $i <= $#argv ; $i++) {
	if ($argv[$i] eq $b) {
	    $r = 1 ;
	}
    }				 
    printf(STDERR "[T/F Option    ] -%s = %d\n",$Option,$r);
    return $r;
}				


sub ParsePDBAtom {
    local($_) = @_ ;
    local($iser)   = substr($_, 7,5);  
    local($atnam)  = substr($_,12,4);  
    local($resnam) = substr($_,17,4);  
    local($chnnam) = substr($_,21,1);  
    local($iresn)  = substr($_,22,4); 
    local($x)      = substr($_,30,8);  
    local($y)      = substr($_,38,8);  
    local($z)      = substr($_,46,8);  
    local($occ)    = substr($_,56,6);  
    local($b)      = substr($_,60,6);  
    local($segid)  = substr($_,67,10);  
    local(@list) = ($iser,$atnam,$resnam,
	   $chnnam,$iresn,$x,$y,$z,$occ,$b,$segid);
    foreach (@list) {
	s/ +//g ;
    }
    return(@list)
}

sub hello {
    local($host) = `hostname` ;
    chop $host ;
    local($date) = `date` ;
    chop $date ;
    $0 =~ /\/([^\/]+)$/ ;
    local($name) = $1;
    
    print STDERR "Hello:  Script $name being interpreted by $ \n" ;
    print STDERR "Hello:  at $date with pid $$ on $host.\n";
}

