use strict;
use warnings FATAL => 'all';

use Test::More tests => 14;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v');

package main;

my $object = T->new;
is_deeply($object->v, undef);

$object->v('u');
my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<form id="v" name="v" method="post" action="u">
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v', default_value => 'u', children => [
		a => 'edit_box', { default_value => 5 }, b => 'edit_box',
]);

package main;

$object = T2->new;
is_deeply($object->v, undef);
is_deeply($object->a, undef);
is_deeply($object->b, undef);

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS
<form id="v" name="v" method="post" action="u">
ENDS
	, a => <<ENDA
<input type="text" name="a" id="a" value="5" />
ENDA
	, b => <<ENDB
<input type="text" name="b" id="b" value="" />
ENDB
	 }) or diag(Dumper($stash));

package T3;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v', default_value => 'u', children => [
		a => 'edit_box', { default_value => 5
			, constraints => [ qw(/^\d+$/) ],
		}, b => 'edit_box',
]);

package main;

$object = T3->new;
$object->a('ff');
is_deeply([ $object->validate_v ], [ 'a', '/^\d+$/' ]);

$object->a(undef);
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<script language="javascript">
function validate_v(form) {
	return validate(form, 'a', /^\d+$/);
}
</script>
<form id="v" name="v" method="post" action="u" onsubmit="return validate_v(this)">
ENDS
	, a => <<ENDA
<input type="text" name="a" id="a" value="5" />
ENDA
	, b => <<ENDB
<input type="text" name="b" id="b" value="" />
ENDB
	 }) or diag(Dumper($stash));

package T4;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v', default_value => 'u', children => [
		a => 'edit_box', { default_value => 5
			, constraints => [ qw(/^\d+$/) ],
		}, b => 'edit_box', { constraints => [ qw(/^\d+$/) ], }
]);

package main;

$object = T4->new;
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<script language="javascript">
function validate_v(form) {
	return validate(form, 'a', /^\d+$/)
		&& validate(form, 'b', /^\d+$/);
}
</script>
<form id="v" name="v" method="post" action="u" onsubmit="return validate_v(this)">
ENDS
	, a => <<ENDA
<input type="text" name="a" id="a" value="5" />
ENDA
	, b => <<ENDB
<input type="text" name="b" id="b" value="" />
ENDB
	 }) or diag(Dumper($stash));

package T5;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v', default_value => 'u', children => [
		a => 'edit_box', , b => 'edit_box',
]);

package main;

$object = T5->new;
$stash = {};

is_deeply([ $object->validate_v ], []);
HTML::Tested::Value::Form::Push_Constraints(
		$object->Widgets_Map->{a}, '/^\d+$/');
is_deeply([ $object->validate_v ], [ 'a', '/^\d+$/' ]);
$object->a(5);
is_deeply([ $object->validate_v ], []);

HTML::Tested::Value::Form::Push_Constraints(
		$object->Widgets_Map->{b}, '/^\d+$/');

$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<script language="javascript">
function validate_v(form) {
	return validate(form, 'a', /^\d+$/)
		&& validate(form, 'b', /^\d+$/);
}
</script>
<form id="v" name="v" method="post" action="u" onsubmit="return validate_v(this)">
ENDS
	, a => <<ENDA
<input type="text" name="a" id="a" value="5" />
ENDA
	, b => <<ENDB
<input type="text" name="b" id="b" value="" />
ENDB
	 }) or diag(Dumper($stash));


