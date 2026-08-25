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
use Path::Try::Error;
use IO::Handle::Common 'dmsg';

# use overload '""' => sub { $_[0]->get_path }, fallback => 1;

our @EXPORT      = qw'path';
our @EXPORT_OKAY = qw'dmsg';

field $path  : reader(get_path);
field $error : reader;
field $param : reader;

ADJUST : params (:$path) { $self->adjust( $path, Path::Tiny::path($path) ) };

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

                # path     => $path,
                meth  => $meth,
                param => $param,

                # lexical  => peek_my(1),
                thrown => $e,

                # status   => $?,
                # errno    => $!,
                autoload => peek_my(0)
            );

            return $error
        }

        if ( scalar @ret == 1 ) {
            my $ret_class = blessed( $ret[0] );
            return $ret[0] && $ret[0]->isa('Path::Tiny')
              ? $class->new( 'path' => $ret[0] )
              : $ret[0];
        }
        elsif ( scalar @ret > 1 && $ret[0] ) {

            return
              map { $_->isa('Path::Tiny') ? $class->new( 'path' => $_ ) : $_ }
              @ret;
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

Path::Tiny::Try - Path::Tiny wrapper with e

=head1 SYNOPSIS

    use Path::Tiny::Try;

=head1 DESCRIPTION

Path::Tiny::Try is ...

=head1 LICENSE

Copyright (C) Ian P Bradley.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ian P Bradley E<lt>ian.bradley@studiocrabapple.comE<gt>

=cut

