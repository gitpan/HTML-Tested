use strict;
use warnings FATAL => 'all';

use Test::More tests => 7;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested::List'); 
}

package LR;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget("HTML::Tested::Value", 'v3', column_title => 'V3');
__PACKAGE__->ht_add_widget("HTML::Tested::Value", 'v2');
__PACKAGE__->ht_add_widget("HTML::Tested::Value", 'v1', column_title => 'V1');

package L;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget("HTML::Tested::List", 'l1', 'LR', render_table => 1);


package L2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget("HTML::Tested::List", 'l1', 'LR');

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

bless $object, 'L2';
$stash = {};
$object->ht_render($stash);
is_deeply($stash, { l1 => [ { v1 => '1a', v2 => '2a', v3 => '3a' }, 
				{ v1 => '1b', v2 => '2b', v3 => '3b' } ]
}) 
	or diag(Dumper($stash));

eval {
package L3;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget('HTML::Tested::List', 'l1', 'L2', render_table => 1);
};

package main;
like($@, qr/No columns found!/);


