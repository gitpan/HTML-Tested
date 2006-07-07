use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Upload;
use base 'HTML::Tested::Value';

sub value_to_string {
	my ($self, $name, $val) = @_;
	return <<ENDS
<input type="file" id="$name" name="$name" />
ENDS
}

1;
