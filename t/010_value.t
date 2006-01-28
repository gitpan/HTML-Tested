use strict;
use warnings FATAL => 'all';

use Test::More tests => 11;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
}

my %_request_args;

package FakeRequest;

sub param {
	my ($class, $n, $v) = @_;
	$_request_args{$n} = $v if (defined($v));
	return $n ? $_request_args{$n} : (keys %_request_args);
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
is_deeply($stash, { v => 'b', mv => '<!-- mv --> c' }) or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => 'b', mv => 'c' }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
		'This b is ok <!-- mv --> c', { v => 'b', mv => 'c' }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
		'This is not ok c', { mv => 'c' }) ], [
	'Unable to find "<!-- mv --> c" in "This is not ok c"' ]);

HTML::Tested::Test->convert_tree_to_param(ref($object), 'FakeRequest', 
		{ v => 'b', mv => 'c' });
is_deeply(\%_request_args, { v => 'b', mv => 'c' });

$object->mv(undef);
$object->ht_render($stash);
is_deeply($stash, { v => 'b', mv => '<!-- mv --> ' }) or diag(Dumper($stash));

$object->v(undef);
$object->ht_render($stash);
is_deeply($stash, { v => 'xxx', mv => '<!-- mv --> ' }) or diag(Dumper($stash));

