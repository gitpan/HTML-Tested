use strict;
use warnings FATAL => 'all';

use Test::More tests => 4;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); }

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_link('v');

package main;

my $object = T->new({ v => [ 'H', 2 ] });
is_deeply($object->v, [ 'H', 2 ]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<a href="2">H</a>
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_link('v', href_format => 'hello?id=%d&s=%s');

package main;

$object = T2->new({ v => [ 'H', 2, 'b&' ] });

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<a href="hello?id=2&s=b&amp;">H</a>
ENDS
