use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value;

sub new {
	my ($class, $parent, $name, @args) = @_;
	return bless({ name => $name, args => \@args }, $class);
}

sub name { return shift()->{name}; }

sub value_to_string {
	my ($self, $name, $val) = @_;
	return $val;
}

sub render {
	my ($self, $caller, $stash, $id) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	$val = '' unless defined($val);
	$stash->{$n} = $self->value_to_string($id, $val);
}

sub bless_from_tree { return $_[1]; }

1;
