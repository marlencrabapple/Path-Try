#!/usr/bin/env perl
package Path::Try::authortest;

use v5.40;
use lib 'lib';

use IO::Handle::Common;
use TOML::Tiny qw'to_toml';
use Path::Try;
use List::Util 'uniq';

sub by_ext ( $path, %opt ) {
    my %ext = ();

    my $scandir = path($path);

    # would state be safe?
    my %stat = ();
    $stat{ $scandir->absolute } = $scandir->stat;

    my $visit = path($path)->visit(
        sub ( $path, $state ) {

            my $stat = $stat{$path} // $path->stat;
            return unless $stat->isa('File::stat');
            $stat{ $path->absolute } //= $stat;

            dmsg \%stat;

            if (
                my @dev =

                uniq
                map { $_->dev }
                map {
                    $stat{$_} //= $_->isa('File::stat') ? $_ : return $_;
                    $stat{$_}
                } (
                    $stat{$path},
                    ( $stat{ $path->parent->absolute } // $path->parent->stat )
                )

              )
            {
                if ( scalar uniq(@dev) > 1 ) {
                    dmsg( $path, $path->parent,
                        { %stat{ $path->parent->absolute, $path->parent } } );
                    return undef;
                }

                return undef unless scalar(@dev) == 1;
            }

            # if(!stat{$path->parent})

            # return if $path->parent->stat->dev != $path->stat->dev;
            return unless $path->is_file;
            my ($ext) = ( $path->basename =~ /^.+?(?:\.([^\.]+))?$/g );
            $ext //= '';

            # dmsg $path, $state, $ext, \%ext;

            $ext{$ext} //= [];
            push $ext{$ext}->@*, $path;
        },
        { recurse => 1 }
    );

    # dmsg $visit, \%ext;

    say to_toml( \%ext );

    \%ext;
}

#````
# my $path     = path("./");````
# my $realpath = $path->realpath;````
# my @children = $path->children;````
#````
# foreach my $line ( path("cpanfile"````)->lines_utf8 ) {
# print $line;````
# }````
#````
# dmsg $path, $realpath, \@children;````
#````
# my $mkerr = path("/fdsfdsfsdfsdf")````;
# dmsg $mkerr;````
#````
# my $err = $mkerr->children;

# if ($err) {
#     dmsg $err;
# }

by_ext( $ENV{HOME} )
