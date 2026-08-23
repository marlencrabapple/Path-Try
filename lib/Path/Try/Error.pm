use Object::Pad ':experimental(:all)';

package Path::Try::Error;

class Path::Try::Error : does(Path::Try::Base);

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use vars qw'@EXPORT';
@EXPORT = qw(Throw);

use IO::Handle::Common qw'dmsg';

field $instance : param(self) : reader;    #: reader(self);
field $path     : reader;
field $meth     : param : reader;
field $param    : reader;
field $lexical  : reader : param //= {};
field $thrown   : param  : reader;

field $status : param :
  reader { peek_my(1)->{'$?'}->$* if refstr( peek_my(1)->{'$?'} ) eq 'HASH' };
field $oserr : param :
  reader { peek_my(1)->{'$?!'}->$* if refstr( peek_my(1)->{'$?'} ) };

ADJUST : params (%params) { $self = $params{self} if $params{self} };
ADJUST : params (:$path)  { $self->adjust( $path,  $path  // $self->path ) };
ADJUST : params (:$param) { $self->adjust( $param, $param // $self->param ) };

# ADJUST : params (:$lexical)

sub bool {
    dmsg \@_;
    __PACKAGE__->undef;
}

method e {
    $thrown;
}

sub Throw (%param) {
    my $err = __PACKAGE__->new(%param);
    $err;
}

use overload 'fallback' => sub ($self) { dmsg $self, $self }, bool => \&bool;
