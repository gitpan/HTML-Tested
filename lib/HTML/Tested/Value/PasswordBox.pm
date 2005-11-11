use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::PasswordBox;
use base 'HTML::Tested::Value';

sub value_to_string {
	my ($self, $name, $val) = @_;
	return <<ENDS;
<input type="password" name="$name" id="$name" value="$val" />
ENDS
}

1;
