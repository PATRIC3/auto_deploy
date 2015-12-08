#!/usr/bin/perl -w
use strict;

my $log_dir = shift or die "no dir provided";
my $tmp_dir = "/tmp";
my $email_list = 'brettint@gmail.com,olson@mcs.anl.gov,dmachi@vbi.vt.edu,rwill1@vbi.vt.edu';
my $errors;

opendir(my $dh, $log_dir) || die "can't opendir $log_dir: $!";
my @logs = grep { /\.log$/ && -f "$log_dir/$_" } readdir($dh);
closedir $dh;


foreach my $log (@logs) {

	print $log, "\n";
	open LOG, "<$log_dir/$log" or die "can't open $log: $!";

	while(<LOG>) {
		chomp;
		push @{$errors->{$log}}, $_ if /BUILD ERROR/;
	}	
	close LOG;
}


my $message;
foreach my $log (keys %$errors) {
	foreach my $error (@{$errors->{$log}}) {
		$message .= "$log\t$error\n";
	}
}

$message = "no build errors" unless defined $message;
print "build errors:\n$message"
;
open M, "|mailx -s \"nightly build\" $email_list";
print M "Build Results\n\n";
print M $message;
close M;

# alternative way to send the message
# open TMP, ">$tmp_dir/build-results.$$"
#   or die "cannot open tmp_dir/build-results.$$";
# print TMP "Build Results\n\n";
# print TMP $message;
# close TMP;
# !system "mailx -s nightly-build $email_listt\@gmail.com < $tmp_dir/build-results.$$"
# 	or die "could not send message: $message\n$!";
# unlink "$tmp_dir/build-results.$$";
