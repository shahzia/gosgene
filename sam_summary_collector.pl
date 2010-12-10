use strict;
use warnings;
use Getopt::Long;
use IO::File;
use Data::Dumper;

#Pick up script name automatically for usage message
my $script=substr($0, 1+rindex($0,'/'));

#Set usage message
my $usage="Usage: $script -workplacelist directoryfilename -ext sam_summary_extension -output output_global_summary\nPlease try again.\n\n\n";

#Declare all variables needed by GetOpt
my ($workplacelist, $extension, $output);

#Get command-line parameters with GetOptions, and check that all needed are there, otherwise die with usage message
die $usage unless 
	&GetOptions(	'workplacelist:s' => \$workplacelist,
					'ext:s' => \$extension,
					'output:s' => \$output
					)
	&& $workplacelist && $extension && $output;
	
my %samsummaries;
	
my $directories = open (DIR, $workplacelist);

open (ALL,">$output");

while (<DIR>) {

	chomp();
	my $directory = $_;
	print STDERR "\n\nmoving to directory ".$directory."\n";
	chdir $directory;
	
	my $list =`ls *$extension`;
	chomp ($list);
	my @samsummarylist = split (/\n/, $list);
	
	
	foreach my $samsummaryfile (@samsummarylist) {
	
		print STDERR "reading file $samsummaryfile\n";
	
		open (SUM, $samsummaryfile) or die $!;
		my $line=1;
		while (<SUM>){
		
			if ($line==1) {$line++; next;}
			chomp();
			my @info = split("\t",$_);
			
			push (@{$samsummaries{$samsummaryfile}},$info[1]);
		
		}
		close(SUM);
	
	}
}

print STDERR "\nprinting header for $output\n";

print ALL "file\tunmapped_reads\tmapped_paired_reads\tmapped_non-paired_reads\tpcr_optical_duplicates\ttotal_reads\n";

foreach my $summaryfile (keys %samsummaries) {
	
	print STDERR "writing data for $summaryfile\n";
	
	my @readsinfo = @{$samsummaries{$summaryfile}};
	my $infoline = join("\t",@readsinfo);
	
	print ALL "$summaryfile\t$infoline\n";

}

close(ALL);
print STDERR "job completed\n";