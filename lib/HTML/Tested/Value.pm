use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value;
use HTML::Entities;

sub new {
	my ($class, $parent, $name, %args) = @_;
	$args{default_value} = '' unless exists($args{default_value});
	return bless({ name => $name, args => \%args }, $class);
}

sub name { return shift()->{name}; }

sub value_to_string {
	my ($self, $name, $val) = @_;
	return $val;
}

sub encode_value {
	my ($self, $val) = @_;
	die "Non scalar value $val" if ref($val);
	return encode_entities($val);
}

sub render {
	my ($self, $caller, $stash, $id) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	$val = defined($val) ? $self->encode_value($val) 
				: $self->{args}->{default_value};
	$stash->{$n} = $self->value_to_string($id, $val);
}

sub bless_from_tree { return $_[1]; }

1;
