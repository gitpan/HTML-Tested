use strict;
use warnings FATAL => 'all';
use Encode;

use Test::More tests => 3;

BEGIN { use_ok('HTML::Tested', 'HTV');
	use_ok('HTML::Tested::Value::Marked');
}

package T;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV."::Marked", 'v');

package main;

my $a = Encode::decode('utf-8', 'дед');
my $object = T->new({ v => $a });
my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => "<!-- v --> $a" });

