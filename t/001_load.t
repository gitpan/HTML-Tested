use strict;
use warnings FATAL => 'all';

use Test::More tests => 22;
use Data::Dumper;
use Carp;

BEGIN { use_ok('HTML::Tested');
	use_ok('HTML::Tested::Test');
	use_ok('HTML::Tested::Test::Request');
	$SIG{__DIE__} = sub { confess(@_); };
	$SIG{__WARN__} = sub { diag(Carp::longmess(@_)); }
};

my $r = HTML::Tested::Test::Request->new;
$r->parse_url('/test/url?arg=1&b=c');
is_deeply($r->_param, { arg => 1, b => 'c' });
$r->parse_url('/test/url?arg=1&b&c=&d=');
is_deeply($r->_param, { arg => 1, b => '', c => '', d => '' });
like($r->as_string, qr/arg/);

my $object = HTML::Tested->new();
isa_ok($object, 'HTML::Tested');

package W1;
use base 'HTML::Tested::Value';

sub render {
	my ($self, $caller, $stash) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	$val ||= 'undef';
	$stash->{$n} = $caller->ht_get_widget_option($n, "param1") . " $val";
}

my $w_obj;

package T;
use base 'HTML::Tested';
__PACKAGE__->register_tested_widget('wn1', 'W1', 1);
$w_obj = __PACKAGE__->make_tested_wn1('w', param1 => 'arg1');

package main;
$object = T->new({ w => 'a' });
is($object->w, 'a');
isa_ok($w_obj, 'W1');

# Sometimes options are used for passing opaque values.
# e.g. HTML::Tested::ClassDBI cdbi_bind
is_deeply($w_obj->options, { param1 => 'arg1' });

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

package T2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_value('v');

package main;

is(T2->can("v_param1"), undef);
is(T2->can("v_default_value"), undef);

package T3;
use base 'T2';
__PACKAGE__->make_tested_value('t3');

package main;

$object = T3->new({ v => 1, t3 => 2 });
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 1, t3 => 2 });

$object = T2->new({ v => 1, t3 => 2 });
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => 1 });

