use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Radio;
use base 'HTML::Tested::Value';

sub render {
	my ($self, $caller, $stash, $id) = @_;
	my $n = $self->name;
	my $val = $self->get_value($caller, $id) or return;
	for my $opt (@$val) {
		my $ch = '';
		if (ref($opt) eq 'ARRAY') {
			$ch = 'checked ' if $opt->[1];
			$opt = $opt->[0];
		}
		$stash->{"$n\_$opt"} = <<ENDS
<input type="radio" name="$id" id="$n" value="$opt" $ch/>
ENDS
	}
}

1;

