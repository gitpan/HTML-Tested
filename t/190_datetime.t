use strict;
use warnings FATAL => 'all';

use Test::More tests => 22;
use DateTime;
use HTML::Tested::Test::Request;
use HTML::Tested::Test;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested', 'HTV');
	use_ok('HTML::Tested::Value');
	use_ok('HTML::Tested::Value::DropDown');
}

HTML::Tested::Seal->instance('boo boo boo');

package T;
use base 'HTML::Tested';

__PACKAGE__->ht_add_widget(::HTV, d => is_datetime => '%x');

package main;

my $dt = DateTime->new(year => 1964, month => 10, day => 16);
my $obj = T->new({ d => $dt });
my $stash = {};
$obj->ht_render($stash);
is_deeply($stash, { d => 'Oct 16, 1964' });

$obj->d(undef);
$obj->ht_render($stash);
is_deeply($stash, { d => '' });

my $r = HTML::Tested::Test::Request->new({ _param => { d => 'Oct 27, 1976' } });
$obj = T->ht_convert_request_to_tree($r);
$obj->ht_render($stash);
is_deeply($stash, { d => 'Oct 27, 1976' });

package T2;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV, e => is_datetime => {
		pattern => '%x', locale => 'ru' });

package main;

$r = HTML::Tested::Test::Request->new({ _param => { e => '27.10.1976' } });
$obj = T2->ht_convert_request_to_tree($r);
$stash = {};
$obj->ht_render($stash);
is_deeply($stash, { e => '27.10.1976' });

T2->ht_add_widget(::HTV, id => is_sealed => 1);
$obj->id(555);

my $qs = $obj->ht_make_query_string("hello", "id", "e");
like($qs, qr/^hello\?id/);
unlike($qs, qr/555/);
like($qs, qr/&e=27\.10\.1976/);


$r->parse_url($qs);
isnt($r->param('id'), undef);

$obj = T2->ht_convert_request_to_tree($r);
is($obj->id, 555);
is($obj->e->year, '1976');

is($r->dir_config("Moo"), undef);
$r->dir_config("Moo", "boo");
is($r->dir_config("Moo"), "boo");
$r->dir_config("Moo", undef);
is($r->dir_config("Moo"), undef);

T2->ht_add_widget(::HTV, 'd');
T2->ht_find_widget('d')->setup_datetime_option('%x');
is(T2->ht_find_widget('d')->options->{is_datetime}->pattern, '%x');

my $opts = {};
T2->ht_find_widget('d')->setup_datetime_option('%c', $opts);
is(T2->ht_find_widget('d')->options->{is_datetime}->pattern, '%x');
is($opts->{is_datetime}->pattern, '%c');

package T3;
use base 'HTML::Tested';
__PACKAGE__->ht_add_widget(::HTV . "::DropDown", dd => 0 => { is_sealed => 1 }
		, 1 => { is_datetime => '%x' });

package main;

my $dt1 = DateTime->new(year => 1980, month => 2, day => 14);
my $dt2 = DateTime->new(year => 1985, month => 7, day => 18);
$obj = T3->new({ dd => [ [ 1, $dt1 ] , [ 2, $dt2, 1 ] ] });

$stash = {};
$obj->ht_render($stash);
like($stash->{dd}, qr/Feb 14/);
unlike($stash->{dd}, qr/"2"/);
is_deeply([ HTML::Tested::Test->check_stash(ref($obj), $stash,
		{ HT_SEALED_dd => [ [ 1, $dt1 ], [ 2, $dt2, 1 ] ] }) ], [])
	or diag(Dumper($stash));
