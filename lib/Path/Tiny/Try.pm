#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package Path::Tiny::Try;

class Path::Tiny::Try;

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use Path::Tiny qw'';
use IO::Handle::Common;
use Syntax::Keyword::Try;
use List::Util qw'all';

our @EXPORT = qw'path';

field $path  : writer(set_path);
field $error : reader;

ADJUST : params (:$path) {
    $path = Path::Tiny->new($path);
    $self->set_path($path)
};

method AUTOLOAD (@arg) {
    our $AUTOLOAD;

    $error = undef;

    my ( $class, $meth ) = ( $AUTOLOAD =~ /^(.*)::(.+)$/ );
    my $ref_class     = ref($self);
    my $blessed_class = blessed($self);
    my @ret;

    if ( $path && $self->isa($class) && $path->can($meth) ) {
        try {
            @ret = $path->$meth(@arg);
        }
        catch ($e) {
            say STDERR "$e";
            $error = {
                'path' => $path,
                meth   => $meth,
                args   => \@arg,
                thrown => $e,
            };
            return $self
        }

        if ( scalar @ret == 1 ) {
            my $ret_class = blessed( $ret[0] );
            return $ret_class eq 'Path::Tiny'
              ? $class->new( 'path' => $ret[0] )
              : $ret[0];
        }
        elsif ( scalar @ret > 1 && $ret[0] ) {

            return map { ref($_) eq 'Path::Tiny' ? path($_) : $_ } @ret;
        }

    }
    elsif ( $meth eq 'DESTROY' ) {
        $path = undef;
        $self = undef;
    }
    else {
        say STDERR "$class does not have a method named '$meth'";
        exit "eval $class->$meth";
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

