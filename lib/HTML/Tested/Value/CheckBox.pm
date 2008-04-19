use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::CheckBox;
use base 'HTML::Tested::Value::Array';

sub transform_value {
	my ($self, $caller, $val) = @_;
	$val = [ 1, $val ] if (!$val || !ref($val));
	return $self->SUPER::transform_value($caller, $val);
}

sub merge_one_value {
	my ($self, $root, $val, @path) = @_;
	my $n = $self->name;
	push @{ $root->$n }, $val;
}

sub value_to_string {
	my ($self, $name, $val) = @_;
	my $che = $val->[1] ? " checked" : "";
	return <<ENDS
<input type="checkbox" id="$name" name="$name" value="$val->[0]"$che />
ENDS
}

1;
