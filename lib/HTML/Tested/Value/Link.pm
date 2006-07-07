use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Link;
use base 'HTML::Tested::Value';
use HTML::Entities;
use Carp;

sub encode_value {
	my ($self, $val) = @_;
	confess "Invalid non-array value: encode_value"
		unless $val && ref($val) eq 'ARRAY';
	return [ map { encode_entities($_) } @$val ];
}

sub seal_value {
	my ($self, $val, $caller) = @_;
	confess "Invalid non-array value: seal_value"
		unless $val && ref($val) eq 'ARRAY';
	my $cap = $caller->ht_get_widget_option($self->name, "caption");
	my $f = shift(@$val) unless defined $cap;
	my @res = map { HTML::Tested::Seal->instance->encrypt($_) } @$val;
	unshift @res, $f if defined $f;
	return \@res;
}

sub value_to_string {
	my ($self, $id, $val, $caller) = @_;
	my $n = $self->name;
	my $l = $caller->ht_get_widget_option($n, "caption");
	$l = shift(@$val) unless defined($l);

	my $f = $caller->ht_get_widget_option($n, "href_format");

	confess "Invalid value in $id link"
		unless ($val && ref($val) eq 'ARRAY');

	my $h = $f ? sprintf($f, @$val) : $val->[0];
	return <<ENDS
<a id="$id" href="$h">$l</a>
ENDS
}

1;
