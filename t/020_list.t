use strict;
use warnings FATAL => 'all';

use Test::More tests => 21;
use Data::Dumper;
use Carp;


BEGIN { $SIG{__DIE__} = sub { confess("# " . $_[0]); };
};

BEGIN { use_ok('HTML::Tested::List'); 
	use_ok('HTML::Tested::Test'); 
}

my $id = 1;

package L;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'LR');

package LR;
use base 'HTML::Tested';
__PACKAGE__->make_tested_marked_value('v1');

sub ht_id { return $id++; }

package main;

my $object = L->new({ l1 => [] });
is_deeply($object->l1, []);

$object->l1([ map { LR->new({ v1 => $_ }) } qw(a b) ]);
my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { l1 => [ { v1 => '<!-- l1__1__v1 --> a' }, 
				{ v1 => '<!-- l1__2__v1 --> b' } ] }) 
	or diag(Dumper($stash));
is($id, 3);
is($object->l1_containee, 'LR');

my %_request_args;
package FakeRequest;

sub param {
	my ($class, $n, $v) = @_;
	$_request_args{$n} = $v if (defined($v));
	return $n ? $_request_args{$n} : (keys %_request_args);
}

package main;

%_request_args = (l1__2__v1 => 'b', l1__1__v1 => 'a', );
my $tree ={ l1 => [ { ht_id => 1, v1 => 'a' }, { ht_id => 2, v1 => 'b' }, ] };
my $res = L->ht_convert_request_to_tree('FakeRequest');
isa_ok($res, 'L');
is_deeply($res, $tree) or diag(Dumper($res));
is($res->l1->[1]->v1, 'b');

is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
			{ l1 => [ { ht_id => 1, v1 => 'a' }, 
					{ ht_id => 2, v1 => 'b' } ] }) ], []);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
			{ l1 => [ { ht_id => 1 }, { ht_id => 2 } ] }) ], []);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
			{ l1 => [ { ht_id => 1, xxxx => 'ddd' }, 
					{ ht_id => 2 } ] }) ], [
		'Unknown widget xxxx found in expected!' ]);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), $stash,
			{ l1 => [ { ht_id => 1 }, ] }) ], [
q#Stash $VAR1 = {
          'v1' => '<!-- l1__2__v1 --> b'
        };
differ from expected $VAR1 = undef;
# ]);

is_deeply([ HTML::Tested::Test->check_text(ref($object),
			'<!-- l1__1__v1 --> a <!-- l1__2__v1 --> b',
			{ l1 => [ { ht_id => 1, v1 => 'a' }, 
					{ ht_id => 2, v1 => 'b' } ] }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object),
			'<!-- l1__1__v1 --> a b',
			{ l1 => [ { ht_id => 1, v1 => 'a' }, 
					{ ht_id => 2, v1 => 'b' } ] }) ], [
	'Unable to find "<!-- l1__2__v1 --> b" in "<!-- l1__1__v1 --> a b"' ]);

%_request_args = ();
HTML::Tested::Test->convert_tree_to_param(ref($object), 'FakeRequest', 
		{ l1 => [ { ht_id => 1, v1 => 'a' }, 
					{ ht_id => 2, v1 => 'b' } ] });
is_deeply(\%_request_args, { l1__1__v1 => 'a', l1__2__v1 => 'b' })
	or diag(Dumper(\%_request_args));

package NL;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'NLR');

package NLR;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l2', 'LR');

sub ht_id { return $id++; }

package main;

my $nested = NL->new({ l1 => [ map { NLR->new({ l2 => [ 
				map  { LR->new({ v1 => $_ }) } qw(a b) ] }) } 
		(1 .. 2) ]});
$stash = {};
$nested->ht_render($stash);
is_deeply($stash, { l1 => [ { 
	l2 => [ { v1 => '<!-- l1__3__l2__4__v1 --> a' }, 
				{ v1 => '<!-- l1__3__l2__5__v1 --> b' } ],
}, {
	l2 => [ { v1 => '<!-- l1__6__l2__7__v1 --> a' }, 
				{ v1 => '<!-- l1__6__l2__8__v1 --> b' } ],
} ] }) 
	or diag(Dumper($stash));
is($id, 9);

my $blessed = NL->ht_bless_from_tree({
	l1 => [ { ht_id => 3, l2 => [ { ht_id => 4, v1 => 'a' }, 
					{ ht_id => 5, v1 => 'a' } ] },
		{ ht_id => 6, l2 => [ { ht_id => 7, v1 => 'b' }, 
					{ ht_id => 8, v1 => 'b' } ] }
	] });
is(@{ $blessed->l1 }, 2);
is(@{ $blessed->l1->[1]->l2 }, 2);

package L2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'LR2');

package LR2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_marked_value('v1');
__PACKAGE__->make_tested_value('ht_id');

package main;

%_request_args = ();
HTML::Tested::Test->convert_tree_to_param('L2', 'FakeRequest', 
		{ l1 => [ { ht_id => 1, v1 => 'a' }, 
					{ ht_id => 2, v1 => 'b' } ] });
is_deeply(\%_request_args, { l1__1__v1 => 'a', l1__2__v1 => 'b' })
	or diag(Dumper(\%_request_args));

