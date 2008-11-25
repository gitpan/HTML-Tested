use strict;
use warnings FATAL => 'all';
use Encode;

use Test::More tests => 6;

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

my $s = HTML::Tested::Seal->instance('boo boo boo');
is(Encode::decode_utf8($s->decrypt($s->encrypt($a))), $a);

my $h = "hel\0oo";
is($s->decrypt($s->encrypt($h)), $h);

my $b;
open my $fh, '/dev/urandom';
sysread $fh, $b, 1024;
close $fh;
is($s->decrypt($s->encrypt($b)), $b);
