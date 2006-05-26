use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Link;
use base 'HTML::Tested::Value';
use HTML::Entities;

__PACKAGE__->make_args(qw(caption href_format));

sub encode_value {
	my ($self, $val) = @_;
	return [ map { encode_entities($_) } @$val ];
}


sub value_to_string {
	my ($self, $name, $val, $caller) = @_;
	my $l = ($self->arg($caller, "caption") || shift(@$val));
	my $f = $self->arg($caller, "href_format");
	die "Empty value in $name link" unless $val;
	my $h = $f ? sprintf($f, @$val) : $val->[0];
	return <<ENDS
<a id="$name" href="$h">$l</a>
ENDS
}

1;
