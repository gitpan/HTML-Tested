use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;
use HTML::Tested::Test;

BEGIN { use_ok('HTML::Tested::Value::Snippet');
	use_ok('HTML::Tested', 'HTV');
}

package T;
use base 'HTML::Tested';

__PACKAGE__->ht_add_widget(::HTV, "v");
__PACKAGE__->ht_add_widget(::HTV . "::Snippet", sni => is_trusted => 1);

package main;

my $obj = T->new({ v => "&hi", sni => "<b>[% v %]</b>" });
my $stash = {};
$obj->ht_render($stash);
is_deeply($stash, { v => '&amp;hi', sni => "<b>&amp;hi</b>" });

# two styles of tests are possible: direct comparison and through render
is_deeply([ HTML::Tested::Test->check_stash(ref($obj), $stash, {
			sni => "<b>&amp;hi</b>" }) ], []);
is_deeply([ HTML::Tested::Test->check_stash(ref($obj), $stash, {
			v => "&hi", sni => "<b>[% v %]</b>" }) ], []);
