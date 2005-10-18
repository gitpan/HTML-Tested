use strict;
use warnings FATAL => 'all';

use Test::More tests => 4;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_edit_box('v');

package main;

my $object = T->new({ v => 'b' });
is($object->v, 'b');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="text" name="v" id="v" value="b" />
ENDS

