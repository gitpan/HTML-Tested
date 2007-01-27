use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested', "HTV"); 
	use_ok('HTML::Tested::Test'); 
	use_ok('HTML::Tested::Value::PasswordBox'); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::PasswordBox", 'v');

package main;

my $object = T->new({ v => 'b' });
is($object->v, 'b');

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="password" name="v" id="v" value="b" />
ENDS

