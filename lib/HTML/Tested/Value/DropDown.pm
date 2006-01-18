use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::DropDown;
use base 'HTML::Tested::Value';
use HTML::Entities;

sub encode_value {
	my ($self, $val) = @_;
	return [ map { [ 
		encode_entities($_->[0]), encode_entities($_->[1]), $_->[2]
	] } @$val ];
}

sub value_to_string {
	my ($self, $name, $val) = @_;
	my $options = join("\n", map {
		my $sel = $_->[2] ? " selected" : "";
		"<option value=\"$_->[0]\"$sel>$_->[1]</option>"
	} @$val);
	return <<ENDS;
<select id="$name" name="$name">
$options
</select>
ENDS
}

1;
