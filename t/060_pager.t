use strict;
use warnings FATAL => 'all';

use Test::More tests => 3;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested::List::Pager'); }

my $id = 1;

package L;
use base 'HTML::Tested';
__PACKAGE__->make_tested_list('l1', 'LR', renderers => [
	HTML::Tested::List::Pager->new(2),
	'HTML::Tested::List::Renderer',
]);

package LR;
use base 'HTML::Tested';
__PACKAGE__->make_tested_marked_value('v1');

sub ht_id { return $id++; }

package main;

my $object = L->new({ l1 => [ map { LR->new({ v1 => $_ }) } qw(a b) ] });
my $stash = {};
$object->ht_render($stash);
is_deeply($stash, { l1_current_page => '',
			l1 => [ { v1 => '<!-- l1__1__v1 --> a' }, 
				{ v1 => '<!-- l1__2__v1 --> b' } ] }) 
	or diag(Dumper($stash));
is($object->l1_current_page, undef);

