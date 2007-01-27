use strict;
use warnings FATAL => 'all';

use Test::More tests => 7;
use Data::Dumper;
use HTML::Tested::Test;

BEGIN { use_ok('HTML::Tested', qw(HTV));
	use_ok('HTML::Tested::Value::Link');
}

HTML::Tested::Seal->instance('boo boo boo');

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Link", 'v');

package main;

my $object = T->new({ v => [ 'H', 2 ] });
is_deeply($object->v, [ 'H', 2 ]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<a id="v" href="2">H</a>
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Link", 'v'
		, href_format => 'hello?id=%d&s=%s');

package main;

$object = T2->new({ v => [ 'H', 2, 'b&' ] });

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<a id="v" href="hello?id=2&s=b&amp;">H</a>
ENDS

package T3;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Link", 'v'
		, href_format => 'hello?id=%d&s=%s', caption => "H");

package main;

$object = T3->new({ v => [ 2, 'b&' ] });

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<a id="v" href="hello?id=2&s=b&amp;">H</a>
ENDS

package T4;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Link", 'v'
		, href_format => 'hello?s=%s&id=%s'
		, caption => "H", 1 => { is_sealed => 1 });

package main;
$object = T4->new({ v => [ 'b', 12 ] });

$stash = {};
$object->ht_render($stash);
is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
		{ HT_SEALED_v => [ b => 12 ], }) ], [])
	or diag(Dumper($stash));

