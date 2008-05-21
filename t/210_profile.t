use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;
use File::Temp qw(tempdir);
use File::Slurp;

my $td = tempdir('/tmp/210_pro_XXXXXXXX');
chdir $td;
write_file("$td/test.pl", <<'ENDS');
use HTML::Tested::Value;
use HTML::Tested::List;

package LC;
use base 'HTML::Tested';
LC->ht_add_widget('HTML::Tested::Value', "lwid_$_") for (1 .. 50);

package R;
use base 'HTML::Tested';
R->ht_add_widget('HTML::Tested::Value', "rwid_$_") for (1 .. 50);
R->ht_add_widget('HTML::Tested::List', "list", 'LC');

package main;

my $root = R->new({ map { ("rwid_$_", $_) } (1 .. 50) });
$root->list([ map {
	LC->new({ map { ("lwid_$_", $_) } (1 .. 50) });
} (1 .. 100) ]); 

my $s = {};
$root->ht_render($s);

1;
ENDS
is(system("perl -d:DProf $td/test.pl"), 0);
my @res = `dprofpp`;
chdir '/';
unlike($res[4], qr/ht_find_widget/); # first line
