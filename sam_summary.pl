use strict;
use warnings;
use Getopt::Long;
use List::Util qw(sum);
use IO::File;

#Pick up script name automatically for usage message
my $script=substr($0, 1+rindex($0,'/'));

#Set usage message
my $usage="Usage: $script -sam sam_file\nPlease try again.\n\n\n";

#Declare all variables needed by GetOpt
my $samfile;

#Get command-line parameters with GetOptions, and check that all needed are there, otherwise die with usage message
die $usage unless 
	&GetOptions(	'sam:s' => \$samfile
					)
	&& $samfile;
	
my %samflags;
$samflags{"unmapped_reads"} = 0;
$samflags{"mapped_paired_reads"} = 0;
$samflags{"mapped_non-paired_reads"} = 0;
$samflags{"pcr_optical_duplicates"} = 0;

	
open (SAM, $samfile);

my $summary = $samfile.".summary";

open (SUM, ">$summary");

while (<SAM>){

chomp();
my @readinfo = split ("\t",$_);

my $flag = $readinfo[1];

if ($flag & 0x0004) { $samflags{"unmapped_reads"}++;}
else {
	if ($flag & 0x0002) { $samflags{"mapped_paired_reads"}++;}
	else{ $samflags{"mapped_non-paired_reads"}++;}
	if ($flag & 0x0400) { $samflags{"pcr_optical_duplicates"}++;}
}

}

print SUM "type_read\tnumber\n";

my $total = $samflags{"unmapped_reads"} + $samflags{"mapped_paired_reads"} + $samflags{"mapped_non-paired_reads"};

print SUM "unmapped_reads\t".$samflags{"unmapped_reads"}."\n";
print SUM "mapped_paired_reads\t".$samflags{"mapped_paired_reads"}."\n";
print SUM "mapped_non-paired_reads\t".$samflags{"mapped_non-paired_reads"}."\n";
print SUM "pcr_optical_duplicates\t".$samflags{"pcr_optical_duplicates"}."\n";
print SUM "total_reads\t$total\n";

close(SAM);
close(SUM);