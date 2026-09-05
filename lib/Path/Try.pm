#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package Path::Try;

class Path::Try : does(Path::Try::Base);

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use Unicode::UTF8;
use Path::Tiny qw'';
use Syntax::Keyword::Try;
use PadWalker qw'peek_my';
use List::Util 'any';
use Path::Try::Error;
use IO::Handle::Common 'dmsg';

use overload '""' => sub { $_[0]->get_path }, fallback => 1;

our @EXPORT      = qw'path';
our @EXPORT_OKAY = qw'dmsg';

field $path  : reader(get_path);    #: inheritable;
field $error : reader;              #: inheritable      : reader;
field $param : reader;              #   : inheritable;

ADJUST : params (%param) {
    $path = Path::Tiny::path( $param{path} );
    dmsg $path, $self, $param
};

method AUTOLOAD (@arg) {
    $param = \@arg;

    our $AUTOLOAD;

    my ( $class, $meth ) = ( $AUTOLOAD =~ /^(.*)::(.+)$/ );
    my $reftype       = reftype($self);
    my $blessed_class = blessed($self);
    my @ret;

    if ( $path && $self->isa($class) && $path->can($meth) ) {
        $error = undef;

        try {
            @ret = $path->$meth(@arg);
        }
        catch ($e) {
            say STDERR "$e";

            $error = Throw(
                self => $self,

                path  => $path,
                meth  => $meth,
                param => $param,

                lexical => peek_my(1),
                thrown  => $e,

                status   => $?,
                oserr    => $!,
                autoload => peek_my(0)
            );

            $self, return $error
        }

        if ( scalar @ret == 1 ) {
            my $ret_class = blessed( $ret[0] );
            return
                $ret_class && $ret[0] && $ret[0]->isa('Path::Tiny')
              ? $class->new( 'path' => $ret[0] )
              : $ret[0];
        }
        elsif ( scalar @ret > 1 && $ret[0] ) {

            return map {
                $_ && $_->isa('Path::Tiny') ? $class->new( 'path' => $_ ) : $_
            } @ret;
        }

    }
    elsif ( $meth eq 'DESTROY' ) {
        $path = undef;
        $self = undef;
    }
    else {
        say STDERR "$class does not have a method named '$meth'";
        return undef;
    }
}

sub path ($path) {
    my $self = __PACKAGE__->new( 'path' => Path::Tiny::path($path) );
}

__END__

=encoding utf-8

=head1 NAME

Path::Try - Path::Tiny wrapper for seamless file operations on potentially bad paths and oddly encoded file content

=head1 SYNOPSIS

    package Path::Try::Example;

    use v5.44;

    use Path::Try;
    use List::Util qw'any';

    our @paths;

    sub add_paths (@path) {
        foreach my $line (
            grep {
                # No need to print errors manually, if used with qw':debug' or
                # environment variable PATH_TRY_DEBUG=1, Path::Tiny construction
                # parameters, caller and internal lexical variables, exception
                # text, etc. will be printed automatically with a stack trace

                $_->isa('Path::Try::Error')
            }    # Remove paths that threw an error
            map { path($_)->realpath }    # Check if filesystem can resolve path
            map { path($_)->lines_utf8( { chomp => 1 } ) }
            @path    # Read list of paths without dieing, even in case of bad
            # content encoding, non-existent paths, mixed absolute and relative
            # paths, path separatorrs, temporary network outages or local resource
            # over-utilization, etc.
        )
        {
            if ( my $path = path($line)->realpath ) {
                push @paths, $path
                unless any { $_ eq $path || $_->digest eq $path->digest }
                @paths    # Avoid duplicates (by path or by file checksum)
            }
        }
    }


=head1 DESCRIPTION

Path::Try is a no-fail wrapper around Path::Tiny that removes the tedium of mid-job failure due to filesystem error or content encoding issues on paths that may be non-existent, inaccessible, or otherwise problematic.

...

=head1 LICENSE

Copyright (C) Ian P Bradley.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ian P Bradley E<lt>ian.bradley@studiocrabapple.comE<gt>

=cut

