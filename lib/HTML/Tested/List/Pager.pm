use strict;
use warnings FATAL => 'all';

package HTML::Tested::List::Pager;

sub new {
	my ($class, $entries_per_page) = @_;
	return bless({ entries_per_page => $entries_per_page }, $class);
}

sub entries_per_page { return shift()->{entries_per_page}; }

sub init {
	my ($self, $the_list, $parent) = @_;
	my $ln = $the_list->name;
	$parent->make_tested_value("$ln\_current_page");
}

sub render {
}

1;
