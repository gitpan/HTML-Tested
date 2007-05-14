use strict;
use warnings FATAL => 'all';

use Test::More tests => 10;
use Data::Dumper;
use HTML::Tested::Test;

BEGIN { use_ok('HTML::Tested', "HTV"); 
	use_ok('HTML::Tested::Value::CheckBox');
}

HTML::Tested::Seal->instance('boo boo boo');

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::CheckBox", 'v');

package main;

my $object = T->new({ v => [ 1 ] });
is_deeply($object->v, [ 1 ]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" />
ENDS

push @{ $object->v }, 1;
is_deeply($object->v, [ 1, 1 ]);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" checked />
ENDS

$object->v->[0] = '1&';
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1&amp;" checked />
ENDS

$object->v(1);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" checked />
ENDS

$object->v(undef);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" />
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::CheckBox", v => 0 => { is_sealed => 1 });

package main;

$object = T2->new({ v => [ 12 ] });
$stash = {};
$object->ht_render($stash);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
		{ HT_SEALED_v => [ 12 ], }) ], [])
	or diag(Dumper($stash));

