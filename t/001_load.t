use strict;
use warnings FATAL => 'all';

use Test::More tests => 12;
use Data::Dumper;
use Carp;

BEGIN { use_ok('HTML::Tested');
	use_ok('HTML::Tested::Test');
	$SIG{__DIE__} = sub { confess(@_); };
	$SIG{__WARN__} = sub { diag(Carp::longmess(@_)); }
};

my $object = HTML::Tested->new();
isa_ok($object, 'HTML::Tested');

package W1;
use base 'HTML::Tested::Value';

sub render {
	my ($self, $caller, $stash) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	$val ||= 'undef';
	$stash->{$n} = $self->{args}->{param1} . " $val";
}

package T;
use base 'HTML::Tested';
__PACKAGE__->register_tested_widget('wn1', 'W1', 1);
__PACKAGE__->make_tested_wn1('w', param1 => 'arg1');

package main;
$object = T->new({ w => 'a' });
is($object->w, 'a');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { w => 'arg1 a' }) or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
			$stash, { w => 'a' }) ], []);
is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
			$stash, { w => 'b' }) ], 
		[ 'Mismatch at w: got "arg1 a", expected "arg1 b"' ]);

my $blessed = T->ht_bless_from_tree({ w => 'a', ggg => 'b' });
is(delete $blessed->{ggg}, 'b');
is_deeply($blessed, $object);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
			$stash, { xxx => 2828 }) ], [
		'Unknown widget xxx found in expected!' ]);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
			$stash, { w => undef }) ], [
		'Mismatch at w: got "arg1 a", expected "arg1 undef"' ]);

$object->w(undef);
$stash = {};
$object->ht_render($stash);
is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
			$stash, { w => undef }) ], []);

