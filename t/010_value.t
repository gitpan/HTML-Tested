use strict;
use warnings FATAL => 'all';

use Test::More tests => 18;
use Data::Dumper;
use HTML::Tested::Test::Request;
use Carp;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
	$SIG{__DIE__} = sub { diag(Carp::longmess(@_)); };
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_value('v', default_value => 'xxx');

package main;

my $object = T->new({ v => 'b' });
is($object->v, 'b');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'b' }) or diag(Dumper($stash));

T->make_tested_marked_value('mv');
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
__PACKAGE__->make_tested_value('ht_id');

package main;

$req = HTML::Tested::Test::Request->new;
HTML::Tested::Test->convert_tree_to_param('T2', $req, { ht_id => 5 });
is_deeply($req->_param, { ht_id => 5});

package T3;
use base 'HTML::Tested';
__PACKAGE__->make_tested_value('v', is_disabled => 1);

package main;

$object = T3->new({ v => 'b' });
is($object->v, 'b');

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => '' }) or diag(Dumper($stash));

is($object->v_is_disabled, 1);
$object->v_is_disabled(undef);
is($object->v_is_disabled, undef);

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 'b' }) or diag(Dumper($stash));


$object = T3->new({ v => 'b' });

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => '' }) or diag(Dumper($stash));

