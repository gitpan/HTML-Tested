use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested', "HTV"); 
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::CheckBox", 'v');

package main;

my $object = T->new({ v => [ 1 ] });
is_deeply($object->v, [ 1 ]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" />
ENDS

push @{ $object->v }, 1;
is_deeply($object->v, [ 1, 1 ]);
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1" checked />
ENDS

$object->v->[0] = '1&';
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="checkbox" id="v" name="v" value="1&amp;" checked />
ENDS

