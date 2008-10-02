use strict;
use warnings FATAL => 'all';

use Test::More tests => 32;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested', qw(HTV HT)); 
	use_ok('HTML::Tested::Value::Form');
	use_ok('HTML::Tested::Value::EditBox');
	use_ok('HTML::Tested::List');
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Form", 'v');

package main;

my $object = T->new;
is_deeply($object->v, undef);

$object->v('u');
my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<form id="v" name="v" method="post" action="u" enctype="multipart/form-data">
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'a', default_value => 5);
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'b');
__PACKAGE__->ht_add_widget(::HTV."::Form", 'v', default_value => 'u');

package main;

$object = T2->new;
is_deeply($object->v, undef);
is_deeply($object->a, undef);
is_deeply($object->b, undef);

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS
<form id="v" name="v" method="post" action="u" enctype="multipart/form-data">
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
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'b');
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'a', default_value => 5
		, constraints => [ [ regexp => '^\d+$' ] ]);
__PACKAGE__->ht_add_widget(::HTV."::Form", 'v', default_value => 'u');

package main;

$object = T3->new;
$object->a('ff');
is_deeply([ $object->ht_find_widget('a')->validate(undef, $object) ]
		, [ [ regexp => '^\d+$' ] ]);

$object->a(undef);
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<form id="v" name="v" method="post" action="u" enctype="multipart/form-data">
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
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'a', default_value => 5
		, constraints => [ [ regexp => '^\d+$' ] ]);
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'b', constraints => [
		[ regexp => '^\d+$' ] ]);
__PACKAGE__->ht_add_widget(::HTV."::Form", 'v', default_value => 'u');

package main;

$object = T4->new;
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<form id="v" name="v" method="post" action="u" enctype="multipart/form-data">
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
__PACKAGE__->ht_add_widget(::HTV."::EditBox", $_) for qw(a b);
__PACKAGE__->ht_add_widget(::HTV."::Form", 'v', default_value => 'u');

package main;

$object = T5->new;
$stash = {};

is_deeply([ $object->ht_find_widget('a')->validate(undef, $object) ], []);
$object->ht_find_widget('a')->push_constraint([ regexp => '^\d+$' ]);
is_deeply([ $object->ht_find_widget('a')->validate(undef, $object) ]
		, [ [ regexp => '^\d+$' ] ]);
$object->a(5);
is_deeply([ $object->ht_find_widget('a')->validate(5, $object) ], []);

$object->ht_find_widget('b')->push_constraint([ 'defined' => '' ]);
is_deeply([ $object->ht_find_widget('b')->validate(undef, $object) ]
		, [ [ 'defined' => '' ] ]);
is_deeply([ $object->ht_find_widget('b')->validate('', $object) ], []);
is_deeply([ $object->ht_find_widget('b')->validate(0, $object) ], []);

$object->ht_render($stash);
is_deeply($stash, { v => <<'ENDS'
<form id="v" name="v" method="post" action="u" enctype="multipart/form-data">
ENDS
	, a => <<ENDA
<input type="text" name="a" id="a" value="5" />
ENDA
	, b => <<ENDB
<input type="text" name="b" id="b" value="" />
ENDB
	 }) or diag(Dumper($stash));

package T6;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::EditBox", 'a', constraints => [
	[ regexp => 'a' ], [ regexp => 'b' ]
]);

package main;

is_deeply([ T6->ht_find_widget('a')->validate('a', 'T6') ]
		, [ [ regexp => 'b' ] ]);
is_deeply([ T6->ht_find_widget('a')->validate('b', 'T6') ]
		, [ [ regexp => 'a' ] ]);
is_deeply([ T6->ht_find_widget('a')->validate('ba', 'T6') ], []);

$object = T6->new;
is_deeply([ $object->ht_validate ], [ [ a => regexp => 'a' ]
					, [ a => regexp => 'b' ] ]);

package T7;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HT."::List", l1 => 'T6');

package main;
$object = T7->new;
is_deeply([ $object->ht_validate ], []);

$object = T7->new({ l1 => [ T6->new({ a => 'bbb' }) ] });
my $res = [ $object->ht_validate ];
is_deeply($res, [ [ l1 => a => regexp => 'a' ] ]) or diag(Dumper($res));

$object->l1->[0]->a("bab");
is_deeply([ $object->ht_validate ], []);

T6->ht_set_widget_option("a", "no_validate", 1);
$object->l1->[0]->a("bb");
is_deeply([ $object->ht_validate ], []);

package T8;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV, v => is_integer => 1);

package main;
$object = T8->new({ v => 'a' });
is_deeply([ $object->ht_validate ], [ [ v => 'integer' ] ]);

$object->v(12);
is_deeply([ $object->ht_validate ], []);

$object->v(undef);
is_deeply([ $object->ht_validate ], []);

$object->v('');
is_deeply([ $object->ht_validate ], [ [ v => 'integer' ] ]);
