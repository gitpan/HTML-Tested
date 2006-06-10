use strict;
use warnings FATAL => 'all';

use Test::More tests => 11;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
}

my $_id = 1;

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_radio('v', default_value => [ 'a', 'b', 'c' ]);

sub ht_id { return $_id++; }

package main;

my $object = T->new;
is($object->v, undef);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v_a => <<ENDS
<input type="radio" name="v" id="v" value="a" />
ENDS
, v_b => <<ENDS
<input type="radio" name="v" id="v" value="b" />
ENDS
, v_c => <<ENDS
<input type="radio" name="v" id="v" value="c" />
ENDS
, }) or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => [ 'a', 'b', 'c' ] }) ], []);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => [ 'a', [ 'b', 1 ], 'c' ] }) ], [
'Mismatch at v_b: got "<input type="radio" name="v" id="v" value="b" />
", expected "<input type="radio" name="v" id="v" value="b" checked />
"'
]);

delete $stash->{v_c};
is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => [ 'a', 'b', 'c' ] }) ], [
'Mismatch at v_c: got undef, expected "<input type="radio" name="v" id="v" value="c" />
"'
]);

$object->v([ 'a', [ 'b', 1 ], 'c' ]);
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v_a => <<ENDS
<input type="radio" name="v" id="v" value="a" />
ENDS
, v_b => <<ENDS
<input type="radio" name="v" id="v" value="b" checked />
ENDS
, v_c => <<ENDS
<input type="radio" name="v" id="v" value="c" />
ENDS
, }) or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_text(ref($object), <<ENDS
<input type="radio" name="v" id="v" value="a" />
<input type="radio" name="v" id="v" value="b" checked />
<input type="radio" name="v" id="v" value="c" />
ENDS
	, { v => [ 'a', [ 'b', 1 ], 'c' ] }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), <<ENDS
<input type="radio" name="v" id="v" value="a" />
<input type="radio" name="v" id="v" value="b" checked />
<input type="radio" name="v" id="v" value="c" />
ENDS
	, { v => [ 'a', [ 'b', 1 ], [ 'c', 1 ] ] }) ], [
'Unable to find "<input type="radio" name="v" id="v" value="c" checked />
" in "<input type="radio" name="v" id="v" value="a" />
<input type="radio" name="v" id="v" value="b" checked />
<input type="radio" name="v" id="v" value="c" />
"'
]);


package L;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'T');

package main;

$object = L->new({ l1 => [ map { T->new({ v => $_ }) }
				[ [ 'a', 1 ], 'b', 'c' ]
				, [ 'a', 'b', [ 'c', 1 ] ] ] });
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { l1 => [ { v_a => <<ENDS
<input type="radio" name="l1__1__v" id="v" value="a" checked />
ENDS
, v_b => <<ENDS
<input type="radio" name="l1__1__v" id="v" value="b" />
ENDS
, v_c => <<ENDS
<input type="radio" name="l1__1__v" id="v" value="c" />
ENDS
}, { v_a => <<ENDS
<input type="radio" name="l1__2__v" id="v" value="a" />
ENDS
, v_b => <<ENDS
<input type="radio" name="l1__2__v" id="v" value="b" />
ENDS
, v_c => <<ENDS
<input type="radio" name="l1__2__v" id="v" value="c" checked />
ENDS
} ], }) or diag(Dumper($stash));

