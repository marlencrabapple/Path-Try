#!/usr/bin/env perl
package asdf;
use lib 'lib';

use v5.40;
use IO::Handle::Common;
use Path::Tiny::Try;

my $path     = path("./");
my $realpath = $path->realpath;
my @children = $path->children;

foreach my $line ( path("cpanfile")->lines_utf8 ) {
    print $line;
}

dmsg $path, $realpath, \@children;

my $mkerr = path("/fdsfdsfsdfsdf");

dmsg $mkerr;
my $err = $mkerr->children;
dmsg $err;

if ($err) {
    dmsg $err;
}
