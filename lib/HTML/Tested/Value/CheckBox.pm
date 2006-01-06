use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::CheckBox;
use base 'HTML::Tested::Value';

sub value_to_string {
	my ($self, $name, $val) = @_;
	my $che = $val->[1] ? " checked" : "";
	return <<ENDS
<input type="checkbox" id="$name" name="$name" value="$val->[0]"$che />
ENDS
}

1;
