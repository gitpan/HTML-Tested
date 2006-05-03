use strict;
use warnings FATAL => 'all';

use Test::More tests => 8;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_submit('v');

package main;

my $object = T->new({ v => 'b' });
is($object->v, 'b');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="submit" name="v" id="v" value="b" />
ENDS

$object->v('>b');
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="submit" name="v" id="v" value="&gt;b" />
ENDS

$object->v(undef);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="submit" name="v" id="v" />
ENDS

package T2;
use base 'HTML::Tested';
__PACKAGE__->make_tested_submit('v', default_value => 'b');

package main;

$object = T2->new;
is($object->v, undef);

$stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="submit" name="v" id="v" value="b" />
ENDS

