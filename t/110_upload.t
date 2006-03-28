use strict;
use warnings FATAL => 'all';

use Test::More tests => 8;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test::Request');
}

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_upload('v');

package main;

my $object = T->new;
is_deeply($object->v, undef);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { v => <<ENDS }) or diag(Dumper($stash));
<input type="file" id="v" name="v" />
ENDS

my $req = HTML::Tested::Test::Request->new({ _uploads => {
		v => 'c.txt' } });
is(scalar($req->upload), 1);
is(($req->upload)[0]->name, 'v');
is(($req->upload)[0]->filename, 'c.txt');

my $res = T->ht_convert_request_to_tree($req);
is($res->v, 'c.txt');

