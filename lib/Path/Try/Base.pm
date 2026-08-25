use Object::Pad ':experimental(:all)';

package Path::Try::Base;

role Path::Try::Base;

our $VERSION = "0.01";

use v5.40;
use utf8;

use parent 'Exporter';

use vars qw'@EXPORT';
@EXPORT = qw($undef adjust refstr);

use Path::Tiny qw'';
use Syntax::Keyword::Try;
use Const::Fast;
use PadWalker          qw'peek_my var_name';
use IO::Handle::Common qw'dmsg';

const our $undef => undef;
field $undef : reader = $undef;

APPLY {
    use v5.40;
    use utf8;

    use Path::Tiny qw'';
    use Syntax::Keyword::Try;
    use Const::Fast;
    use PadWalker          qw'peek_my var_name';
    use IO::Handle::Common qw'dmsg';

    # __CLASS__->import
}

sub refstr ($ref) {
    reftype($ref) // '';
}

method adjust ( $field, $val ) {
    dmsg peek_my($_) for ( 1 .. 2 );
    my $varname = var_name( 2, \$field );
    dmsg $self, $varname, $field, $val;
    eval "\$$varname = \$val" if $varname;
    dmsg $self, $field, $val, $varname;
    $self;
}
