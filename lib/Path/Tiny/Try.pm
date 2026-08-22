#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package Path::Tiny::Try;

class Path::Tiny::Try;

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use Path::Tiny::Try::Error;
use Unicode::UTF8;
use Sub::Util          qw'subname';
use Path::Tiny         qw'';
use IO::Handle::Common qw'dmsg';
use Syntax::Keyword::Try;

our @EXPORT = qw'path';

field $path  : writer(set_path);
field $error : reader;
field $arg   : reader;

ADJUST : params (:$path) {
    $path = Path::Tiny->new($path);
    $self->set_path($path)
};

method AUTOLOAD (@arg) {

    $arg = \@arg;
    our $AUTOLOAD;

    $error = undef;

    my ( $package, $meth ) = ( $AUTOLOAD =~ /^(.*)::(.+)$/ );
    my $reftype = reftype($self);
    my $class   = blessed($self);
    my @ret;

    # dmsg $self, $AUTOLOAD, $package, $class, $reftype, $meth, $arg;

    if ( $path && $self->isa($package) && $path->can($meth) ) {
        try {
            dmsg $self, $path, $meth, \@arg;
            @ret = $path->$meth(@arg);
        }
        catch ($e) {
            say STDERR "$e";

            $error = Throw(
                self    => $self,
                path    => $path,
                meth    => $meth,
                arg     => \@arg,
                lexical => peek_my(1),
                thrown  => $e,
                $? ? ( status => $? ) : (),
                $! ? ( errno  => $! ) : (),
            );

            return $self, $error
        }

        if ( scalar @ret == 1 ) {
            my $ret_class = blessed( $ret[0] );
            return $ret_class && $ret_class eq 'Path::Tiny'
              ? $class->new( 'path' => $ret[0] )
              : $ret[0];
        }
        elsif ( scalar @ret > 1 && $ret[0] ) {

            return
              map { ref($_) eq 'Path::Tiny' ? $class->new( path => $_ ) : $_ }
              @ret;
        }
        else {
            dmsg \@ret;
            return @ret;
        }

    }
    elsif ( $meth eq 'DESTROY' ) {

        $path = undef;

        #$self = undef;
        return $self;
    }
    else {
        say STDERR "$class does not have a method named '$meth'";
        return $self;

        # exit "eval $class->$meth";
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

