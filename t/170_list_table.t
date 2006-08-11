use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested::List'); 
}

package L;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'LR');

package LR;
use base 'HTML::Tested';
__PACKAGE__->make_tested_value('v3', column_title => 'V3');
__PACKAGE__->make_tested_value('v2');
__PACKAGE__->make_tested_value('v1', column_title => 'V1');

package main;

is_deeply([ map { $_->name } @{ LR->Widgets_List } ], [ qw(v3 v2 v1) ]);
is(L->ht_get_widget_option("l1", "some_opt"), undef);

my $object = L->new({ l1 => [] });
is_deeply($object->l1, []);

$object->l1([ map {
	LR->new({ v1 => "1$_", v2 => "2$_", v3 => "3$_" })
} qw(a b) ]);

my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { l1 => [ { v1 => '1a', v2 => '2a', v3 => '3a' }, 
				{ v1 => '1b', v2 => '2b', v3 => '3b' } ]
	, l1_table => <<ENDS
<table>
<tr>
<th>V3</th>
<th>V1</th>
</tr>
<tr>
<td>3a</td>
<td>1a</td>
</tr>
<tr>
<td>3b</td>
<td>1b</td>
</tr>
</table>
ENDS
}) 
	or diag(Dumper($stash));

