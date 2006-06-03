use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value;
use base 'Class::Data::Inheritable';
use HTML::Entities;

__PACKAGE__->mk_classdata('Arg_Names', []);

sub make_args {
	my ($class, @names) = @_;
	my $an = $class->Arg_Names;
	$class->Arg_Names([ @$an, @names ]);
}

__PACKAGE__->make_args(qw(default_value is_disabled is_trusted));

sub arg {
	my ($self, $parent, $arg_name) = @_;
	my $fname = $self->name . "_$arg_name";
	return exists $parent->{$fname} ?
		$parent->{$fname} : $self->{_args}->{$arg_name};
}

sub _make_arg_accessors {
	my ($self, $parent, $arg_name) = @_;
	my $fname = $self->name . "_$arg_name";
	no strict 'refs';
	*{ "$parent\::$fname" } = sub {
		my $this = shift;
		$this->{ $fname } = shift if @_;
		return $self->arg($this, $arg_name);
	};
}

sub new {
	my ($class, $parent, $name, %args) = @_;
	my $self = bless({ name => $name, _args => \%args }, $class);
	$self->_make_arg_accessors($parent, $_) for @{ $self->Arg_Names };
	return $self;
}

sub name { return shift()->{name}; }
sub args { return shift()->{_args}; }

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
	my $res = '';
	my $n = $self->name;
	goto OUT if $self->arg($caller, "is_disabled");

	my $val = $caller->$n;
	if (defined($val)) {
		$val = $self->encode_value($val)
			unless $self->arg($caller, "is_trusted");
	} else {
		$val = $self->arg($caller, "default_value");
		$val = $val->($self, $id, $caller)
			if (defined($val) && ref($val) eq 'CODE');
		$val = '' unless defined($val);
	}
	$res = $self->value_to_string($id, $val, $caller);
OUT:
	$stash->{$n} = $res;
}

sub bless_from_tree { return $_[1]; }

1;
