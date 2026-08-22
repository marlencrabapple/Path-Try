use Object::Pad ':experimental(:all)';

package Path::Tiny::Try::Error;

class Path::Tiny::Try::Error;

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use vars qw'@EXPORT';
@EXPORT = qw(Throw);

use PadWalker          qw'';
use IO::Handle::Common qw'';

field $instance : param(self) : reader;    #: reader(self);
field $path     : reader;
field $meth     : param : reader;
field $arg      : reader;
field $lexical  : reader;
field $thrown   : param : reader;
field $status   : param : reader = peek_my( 1, $? );
field $oserr    : param : reader = peek_my( 1, $! );

ADJUST : params (%params) { $self = $params{self} if $params{self} };
ADJUST : params (:$path)  { $self->adjust( $path // $self->path ) };
ADJUST : params (:$arg)   { $self->adjust( $arg  // $self->arg ) };
ADJUST : params (:$lexical)
  { $self->adjust( $lexical // PadWalker::peek_my(1) ) };

sub bool {
    undef;
}

method adjust ( $field, $val ) {
    eval PadWalker::var_name( 1, $field ) . " = \$val";
    IO::Handle::Common::dmsg $self;
}

method e {
    $thrown;
}

sub Throw (%param) {
    my $err = __PACKAGE__->new(%param);
    IO::Handle::Common::dmsg $err;
    $err;
}

# *Throw = sub (%param) { __PACKAGE__->Throw(%param) };

use overload 'fallback' => sub ($self) { $self }, bool => \&bool;
