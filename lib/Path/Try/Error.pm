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
use PadWalker 'peek_my';
use Path::Try::Base;

field $instance : param(self) : reader;
field $path     : reader;
field $meth     : param : reader;
field $param    : param : reader;
field $lexical  : param : reader = peek_my(1);
field $thrown   : param : reader = "";

field $status : reader;
field $oserr  : reader;

ADJUST : params (:$path) { $self->adjust( $path, $instance->get_path ) };

ADJUST : params (:$status, :$oserr) {
    foreach my ( $field, $lexname ) ( $status, '$?', $oserr, '$!' ) {
        my $lexval_ref = $$lexical{$lexname};
        $self->adjust( $field, $lexval_ref ) if refstr($lexval_ref) eq 'SCALAR';
    }
};

method e {
    $thrown;
}

sub Throw (%param) {
    my $err = __PACKAGE__->new(%param);
    $err;
}

use overload
  'fallback' => sub ($self) { dmsg $self, $self },
  bool       => sub { 0 };
