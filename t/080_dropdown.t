use strict;
use warnings FATAL => 'all';

use Test::More tests => 9;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested', "HTV"); 
	use_ok('HTML::Tested::Test'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::DropDown", 'v');

package main;

my $object = T->new({ v => [
	[ 1, 'a', ],
	[ 2, 'b', ],
] });
is_deeply($object->v, [
	[ 1, 'a', ],
	[ 2, 'b', ],
]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<select id="v" name="v">
<option value="1">a</option>
<option value="2">b</option>
</select>
ENDS
is_deeply($object->v, [
	[ 1, 'a', ],
	[ 2, 'b', ],
]);

push @{ $object->v->[1] }, 1;
is_deeply($object->v, [
	[ 1, 'a', ],
	[ 2, 'b', 1, ],
]);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<select id="v" name="v">
<option value="1">a</option>
<option value="2" selected>b</option>
</select>
ENDS
is_deeply($object->v, [
	[ 1, 'a', ],
	[ 2, 'b', 1, ],
]);

$object->v->[1]->[1] = 'b<';
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<select id="v" name="v">
<option value="1">a</option>
<option value="2" selected>b&lt;</option>
</select>
ENDS

