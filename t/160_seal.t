use strict;
use warnings FATAL => 'all';

use Test::More tests => 28;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested');
	use_ok('HTML::Tested::Test');
	use_ok('HTML::Tested::Test::Request');
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_value('v', is_sealed => 1);

package main;

my $s = HTML::Tested::Seal->instance('boo boo boo');
is_deeply(HTML::Tested::Seal->instance, $s);

my $v = $s->encrypt("hello");
isnt($v, "hello");
is($s->decrypt($v), "hello");
is($s->decrypt("dskdskd"), undef);

# Encrypting twice gives different result. Dependent on Crypt::CBC version.
# isnt($s->encrypt("hello"), $v);

# And length is per 8 byte block
is(length($v), length($s->encrypt("hello1")));

undef $HTML::Tested::Seal::_instance;
my $s2 = HTML::Tested::Seal->instance('boo boo boo');
isnt($s, $s2);
is($s2->decrypt($v), "hello");

my $v2 = $v;
my $res;
for my $i ('a' .. 'z', 0 .. 9) {
	substr($v2, -1) = $i;
	$res = $s->decrypt($v2);
	$res = undef if ($res && $res eq 'hello');
	last if $res;
}
is($res, undef);
is($s->decrypt($v), 'hello');
is(length($v), length($v2));

my $object = T->new({ v => 'hello' });
is($object->v, 'hello');

my $stash = {};
is($object->v_is_sealed, 1);
$object->v_is_sealed(undef);

$object->ht_render($stash);
is_deeply($stash, { v => 'hello' }) or diag(Dumper($stash));

$stash = {};
$object->v_is_sealed(1);
$object->ht_render($stash);
ok(exists $stash->{v});
isnt($stash->{v}, 'hello');
is($s->decrypt($stash->{v}), 'hello');

my $r = HTML::Tested::Test::Request->new({ _param => { v => $stash->{v} } });
$res = T->ht_convert_request_to_tree($r);
is($res->v, 'hello');

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => 'hello' }) ], []);

package T2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_hidden('v', is_sealed => 1);

package main;

$stash = {};
$object = T2->new({ v => 'hello' });
$object->ht_render($stash);
is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => 'hello' }) ], []);

# But we test it anyway... :)
is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => 'hello1' }) ], [
'Mismatch at v: got "<input type="hidden" name="v" id="v" value="hello" />
", expected "<input type="hidden" name="v" id="v" value="hello1" />
"'
]);

package T3;
use base 'HTML::Tested';
__PACKAGE__->make_tested_hidden('h', is_sealed => 1);
__PACKAGE__->make_tested_value('v', is_sealed => 1);

package main;

$stash = {};
$object = T3->new({ h => 'bye', v => 'hello' });
$object->ht_render($stash);
$s = <<ENDS;
<html>
$stash->{h}
$stash->{v}
ENDS

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
		$s, { v => 'hello', h => 'bye' }) ], []);

is_deeply([ HTML::Tested::Test->check_text(ref($object), 
		$s, { v => 'hello', h => 'bye1' }) ], [
'Unable to find "<input type="hidden" name="h" id="h" value="bye1" />
" in "<html>
<input type="hidden" name="h" id="h" value="bye" />

hello
"'
]);

package T4;
use base 'HTML::Tested';
__PACKAGE__->make_tested_link('v', href_format => 'hello?id=%s&s=%s'
		, caption => "H", is_sealed => 1);
package main;

$object = T4->new({ v => [ 2, 'booo' ] });

$stash = {};
$object->ht_render($stash);
unlike($stash->{v}, qr/booo/) or diag(Dumper($stash));

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => [ 2, 'booo' ] }) ], []);

is_deeply([ HTML::Tested::Test->check_stash(ref($object), 
		$stash, { v => [ 2, 'b1ooo' ] }) ], [
'Mismatch at v: got "<a id="v" href="hello?id=2&s=booo">H</a>
", expected "<a id="v" href="hello?id=2&s=b1ooo">H</a>
"'
]);

