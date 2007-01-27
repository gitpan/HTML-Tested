use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Array;
use base 'HTML::Tested::Value';
use Carp;

sub new {
	my $self = shift()->SUPER::new(@_);
	my $opts = $self->options;
	while (my ($n, $v) = each %$opts) {
		next unless ref($v) eq 'HASH';
		my $dto = $v->{is_datetime} or next;
		$self->setup_datetime_option($dto, $v);
	}
	return $self;
}

sub transform_value {
	my ($self, $caller, $val) = @_;
	confess "Invalid non-array value: seal_value"
		unless $val && ref($val) eq 'ARRAY';
	my $opts = $self->options;
	my @res;
	for (my $i = 0; $i < @$val; $i++) {
		my $nopts = $opts->{$i};
		$self->{_options} = $nopts if $nopts;
		push @res, $self->SUPER::transform_value($caller, $val->[$i]);
		$self->{_options} = $opts if $nopts;
	}
	return \@res;
}

sub seal_value {
	my ($self, $val) = @_;
	return $self->options->{isnt_sealed} ? $val
			: $self->SUPER::seal_value($val);
}

1;
