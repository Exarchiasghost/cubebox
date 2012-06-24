#!/usr/bin/perl

use strict;
use Cwd;
use File::Path;


my @repo;
my $ro=0;

@repo = ([
	'git@github.com:0pq76r/cubebox-client.git',
	'git@github.com:0pq76r/cubebox-shared.git',
	'git@github.com:0pq76r/cubebox-server.git',
	'git@github.com:0pq76r/cubebox.git'
	],			
	[
	'git://github.com/0pq76r/cubebox-client.git',
	'git://github.com/0pq76r/cubebox-shared.git',
	'git://github.com/0pq76r/cubebox-server.git',
	'git://github.com/0pq76r/cubebox.git'
	]);


sub help {
	print <<EOF;
===============================================================

Usage:
	./sync-all [-r] [-a]
		[-c Client(Name|Tag|Version|Checksum)]
		[-l Shared(Name|Tag|Version|Checksum)]
		[-s Server(Name|Tag|Version|Checksum)]
		[--clean]
		[--diff (-c|-l|-s|-a) username]
		
	-r		Read only
	-a		Sync Client, Server and Shared		
	-c		Sync Client
	-l		Sync Shared
	-s		Sync Server
	--clean		Remove Subrepos
	--diff		Display diff summary

---------------------------------------------------------------

Examples:
	./sync-all -r -l latest -c Enola -s HEAD
	./sync-all --diff -a Patrick

===============================================================


EOF
	
}

sub diff_sum {
	my $pwd = getcwd();

	if(-d $_[0]){
		chdir($_[0]);
	
		my $gitlog= `git log --author=$_[1] -n 1| cat`;
	
		$gitlog =~ /^\S*\s(\S*)/;
		my $rev=$1;
		print "\n";
		system "git diff $rev HEAD --summary | cat";
		print "\n";
	}
	chdir($pwd);
}

sub main {

	my $pwd = getcwd();
		
    if ($#_ eq -1) {
        help(1);
    }
    
    my @args=@_;
	
	push @args, " ";
	
    while ($#args ne -1) {
        my $arg = shift @args;
        
        if ($arg eq "--help") {
            help(0);
        }
        elsif ($arg eq "-r"){ $ro=1; }
        elsif ($arg eq "-c"){
			if (-d "client/.git") {
				chdir("client");
				system "git pull $repo[$ro][0]";
			}
			else {
				system "mkdir -p client";
				chdir ("client");
				system "git init";
				system "git remote add origin $repo[$ro][0]";
				system "git pull $repo[$ro][0]"
			}
				
			my $arg = shift @args;
			system "git checkout -f $arg";
			chdir $pwd;
		}
        elsif ($arg eq "-l"){
			if (-d "shared/.git") {
				chdir("shared");
				system "git pull $repo[$ro][1]";
			}
			else {
				system "mkdir -p shared";
				chdir ("shared");
				system "git init";
				system "git remote add origin $repo[$ro][1]";
				system "git pull $repo[$ro][1]"
			}
				
			my $arg = shift @args;
			system "git checkout -f $arg";
			chdir $pwd;
		}
        elsif ($arg eq "-s"){
			if (-d "server/.git") {
				chdir("server");
				system "git pull $repo[$ro][2]";
			}
			else {
				system "mkdir -p server";
				chdir ("server");
				system "git init";
				system "git remote add origin $repo[$ro][2]";
				system "git pull $repo[$ro][2]"
			}
				
			my $arg = shift @args;
			system "git checkout -f $arg";
			chdir $pwd;
		}
        elsif ($arg eq "-a"){
			$arg = shift @args;
			if ($arg =~ /^\s/ ) { $arg = "HEAD";}
			push @args, " ";
			unshift @args, "$arg";
			unshift @args, "-s";
			unshift @args, "$arg";
			unshift @args, "-l";
			unshift @args, "$arg";
			unshift @args, "-c";
			system "git pull $repo[$ro][3]"
		}
		elsif ($arg eq "--clean"){
			rmtree "client",0,0;
			rmtree "server",0,0;
			rmtree "shared",0,0;
		}
		elsif ($arg eq "--diff"){
			$arg = shift @args;
			my $uname = shift @args;
			if($arg eq "-s"){
				print "\n";
				print("-"x((63-length("server"))/2)
					."server"."-"x(1+(63-length("server"))/2)."\n");
				diff_sum("server", $uname);
				print(("-"x63)."\n\n");
			}
			if($arg eq "-c"){
				print "\n";
				print("-"x((63-length("client"))/2)
					."client"."-"x(1+(63-length("client"))/2)."\n");
				diff_sum("client", $uname);
				print(("-"x63)."\n\n");
			}
			if($arg eq "-l"){
				print "\n";
				print("-"x((63-length("shared"))/2)
					."shared"."-"x(1+(63-length("shared"))/2)."\n");
				diff_sum("shared", $uname);
				print(("-"x63)."\n\n");
			}
			if($arg eq "-a"){
				print "\n";
				print("-"x((63-length("cubebox"))/2)
					."cubebox"."-"x((63-length("cubebox"))/2)."\n");
				diff_sum(".", $uname);
				printf(("-"x63)."\n\n");
				unshift @args, "$uname";
				unshift @args, "-s";
				unshift @args, "--diff";
				unshift @args, "$uname";
				unshift @args, "-l";
				unshift @args, "--diff";
				unshift @args, "$uname";
				unshift @args, "-c";
				unshift @args, "--diff";
			}
		}
    }
}

main(@ARGV);

 
