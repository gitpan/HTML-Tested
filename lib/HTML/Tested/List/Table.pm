use strict;
use warnings FATAL => 'all';

package HTML::Tested::List::Table;

sub init {}

sub render {
	my ($self, $the_list, $caller, $stash, $id) = @_;
	my $c = $the_list->containee;
	my $ln = $the_list->name;
	my (@cols, @names);
	for my $w (@{ $c->Widgets_List }) {
		my $n = $w->name;
		my $ct = $c->ht_get_widget_option($n, "column_title")
				or next;
		push @cols, $ct;
		push @names, $n;
	}
	return unless @cols;
	my $res = "<table>\n<tr>\n";
	for my $t (@cols) {
		$res .= "<th>$t</th>\n";
	}
	for my $r (@{ $stash->{ $ln } }) {
		$res .= "</tr>\n<tr>\n";
		for my $n (@names) {
			$res .= "<td>" . $r->{$n} . "</td>\n";
		}
	}

	$res .= "</tr>\n</table>\n";
	$stash->{"$ln\_table"} = $res;
}

1;
