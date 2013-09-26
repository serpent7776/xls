#!/usr/bin/env perl
# vim: set ts=4 sw=4:

#
# Copyright © 2013 Serpent7776. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#


$::VERSION='0.10';

use XML::Writer;
use Getopt::Declare;

sub list_dir
{
	my ($dir, $xml, $args) = @_;

	my $r=opendir(my $d, $dir);
	if ($r)
		{
		while($f=readdir($d))
			{
			if ($f=~m/^\.{1,2}$/) {next;}
			if (-d "$dir/$f")
				{
				my @attrs=('name'=>$f);
				$xml->startTag('dir', @attrs);
				if ($args->{'-R'}){
					list_dir("$dir/$f", $xml);
				}
				$xml->endTag('dir');
				}
			else
				{
				my @attrs=(name=>$f);
				$xml->emptyTag('file', @attrs);
				}
			}
		closedir($d);
		}
	else {warn 'cannot open directory '.$dir."\n";}
}

my $getoptspec=q[
	-R	Recursively list subdirectories
	--help	print help
	--version	print version
];

$args=Getopt::Declare->new($getoptspec);

if (scalar(@ARGV)<1 or $args->{'--help'}){
	$args->usage();
}elsif($args->{'--version'}){
	$args->version();
}else{
	$xml=XML::Writer->new(
		NEWLINES=>0,
		DATA_MODE=>1,
		DATA_INDENT=>2
	);
	$xml->startTag('dir-list');
	print $args->{'<dirs>'};
	while(($n,$dir)=each @ARGV)
		{
		list_dir($dir, $xml, $args);
		}
	$xml->endTag('dir-list');
	$xml->end();
}
