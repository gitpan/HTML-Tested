use strict;
use warnings FATAL => 'all';

use Test::More tests => 28;
use Data::Dumper;
use HTML::Tested::Test::Request;

BEGIN { use_ok('HTML::Tested', 'HT'); 
	use_ok('HTML::Tested::Test'); 
	use_ok('HTML::Tested::Value'); 
	use_ok('HTML::Tested::Value::Marked'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HT."::Value", 'v', default_value => 'xxx');

package main;

my $object = T->new({ v => 'b' });
is($object->v, 'b');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'b' }) or diag(Dumper($stash));

T->ht_add_widget(::HT."::Value::Marked", 'mv');
$object->mv('c');
$object->ht_render($stash);
is_deeply($stash, { v => 'b', mv => '<!-- mv --> c' })
	or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => 'b', mv => 'c' }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
	'This b is ok <!-- mv --> c', { v => 'b', mv => 'c' }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
		'This is not ok c', { mv => 'c' }) ], [
	'Unable to find "<!-- mv --> c" in "This is not ok c"' ]);

my $req = HTML::Tested::Test::Request->new;
HTML::Tested::Test->convert_tree_to_param('T', $req
		, { v => 'b', mv => 'c' });
is_deeply($req->_param, { v => 'b', mv => 'c' });

$object->mv(undef);
$object->ht_render($stash);
is_deeply($stash, { v => 'b', mv => '<!-- mv --> ' })
	or diag(Dumper($stash));

$object->v(undef);
$object->ht_render($stash);
is_deeply($stash, { v => 'xxx', mv => '<!-- mv --> ' })
	or diag(Dumper($stash));

package T2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HT."::Value", 'ht_id');

package main;

$req = HTML::Tested::Test::Request->new;
HTML::Tested::Test->convert_tree_to_param('T2', $req, { ht_id => 5 });
is_deeply($req->_param, { ht_id => 5});

package T3;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HT."::Value", 'v', is_disabled => 1);

package main;

$object = T3->new({ v => 'b' });
is($object->v, 'b');

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => '' }) or diag(Dumper($stash));

is($object->ht_get_widget_option("v", "is_disabled"), 1);
$object->ht_set_widget_option("v", "is_disabled", undef);
is($object->ht_get_widget_option("v", "is_disabled"), undef);

eval { $object->ht_get_widget_option("fff", "is_disabled"); };
like($@, qr/Unknown widget fff/);

eval { $object->ht_set_widget_option("fff", "is_disabled", 1); };
like($@, qr/Unknown widget fff/);

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'b' }) or diag(Dumper($stash));


$object = T3->new({ v => 'b' });
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => '' }) or diag(Dumper($stash));

is(T3->ht_get_widget_option("v", "is_disabled"), 1);
T3->ht_set_widget_option("v", "is_disabled", undef);
$object = T3->new({ v => 'b' });
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'b' }) or diag(Dumper($stash));
is($object->ht_get_widget_option("v", "is_disabled"), undef);

package T4;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HT."::Value", 'v', is_trusted => 1, default_value => sub {
	my ($self, $id, $caller) = @_;
	return $self->name . ", $id, " . ref($caller);
});

package main;

$object = T4->new({ v => '&a' });
is($object->v, '&a');

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => '&a' }) or diag(Dumper($stash));

$object->v(undef);
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'v, v, T4' }) or diag(Dumper($stash));

