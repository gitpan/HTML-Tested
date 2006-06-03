use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
}

my $_id = 1;

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_radio('v', choices => [ 'a', 'b', 'c' ]);

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

$object->v('b');
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

package L;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'T');

package main;

$object = L->new({ l1 => [ map { T->new({ v => $_ }) } qw(a c) ] });
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

