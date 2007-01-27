use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::DropDown;
use base 'HTML::Tested::Value::Array';

sub transform_value {
	my ($self, $caller, $val) = @_;
	return [ map { $self->SUPER::transform_value($caller, $_) } @$val ];
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
