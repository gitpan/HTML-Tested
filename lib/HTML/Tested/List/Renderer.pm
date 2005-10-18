use strict;
use warnings FATAL => 'all';

package HTML::Tested::List::Renderer;

sub init {}

sub render {
	my ($self, $the_list, $caller, $stash, $id) = @_;
	my $n = $the_list->name;
	my $rows = $caller->$n;
	my @res;
	for my $row (@$rows) {
		my $s = {};
		my $h = defined($row->{ht_id}) ? $row->{ht_id} : $row->ht_id;
		$row->ht_render($s, $id . "__$h");
		push @res, $s;
	}
	$stash->{$n} = \@res;
}

1;
