use strict;
use warnings FATAL => 'all';

use Test::More tests => 18;
use Data::Dumper;
use File::Temp qw(tempdir);
use File::Slurp;

BEGIN { use_ok('HTML::Tested'); 
	use_ok('HTML::Tested::Test::Request');
	use_ok('HTML::Tested::Test');
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

my $td = tempdir("/tmp/pltest_110_up_XXXXXX", CLEANUP => 1);
write_file("$td/c.txt", "Hello\nworld\n");

my $req = HTML::Tested::Test::Request->new;
$req->add_upload(v => "$td/c.txt");
is(scalar($req->upload), 1);
is(($req->upload)[0]->name, 'v');
is(($req->upload)[0]->filename, 'c.txt');
is(ref(($req->upload)[0]->fh), 'GLOB');

my $res = T->ht_convert_request_to_tree($req);
is(ref($res->v), 'GLOB');
is(read_file($res->v), "Hello\nworld\n");

$req = HTML::Tested::Test::Request->new;
HTML::Tested::Test->convert_tree_to_param('T', $req, { v => "$td/c.txt" });
is_deeply([ $req->param ], []);
is(scalar($req->upload), 1);

my $u = ($req->upload)[0];
is($u->name, 'v');
is($u->filename, 'c.txt');
is(ref($u->fh), 'GLOB');

$req->add_upload(c => "$td/c.txt");
is($req->upload('c')->name, 'c');
is($req->upload('j'), undef);
