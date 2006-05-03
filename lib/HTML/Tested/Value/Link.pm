use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Link;
use base 'HTML::Tested::Value';

use HTML::Entities;

sub encode_value {
	my ($self, $val) = @_;
	return [ map { encode_entities($_) } @$val ];
}


sub value_to_string {
	my ($self, $name, $val) = @_;
	my $l = ($self->args->{caption} || shift(@$val));
	my $f = $self->args->{href_format};
	my $h = $f ? sprintf($f, @$val) : $val->[0];
	return <<ENDS
<a id="$name" href="$h">$l</a>
ENDS
}

1;
