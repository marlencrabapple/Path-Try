#!/usr/bin/env perl
package asdf;
use lib 'lib';

use v5.40;
use Path::Tiny::Try;
use IO::Handle::Common;

my $path     = path("./");
my $realpath = $path->realpath;
my @children = $path->children;

foreach my $line ( path("cpanfile")->lines_utf8 ) {
    print $line;
}

dmsg $path, $realpath, \@children;
