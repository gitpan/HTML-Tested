use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value;
use base 'Class::Data::Inheritable';
use HTML::Entities;
use HTML::Tested::Seal;

__PACKAGE__->mk_classdata('Arg_Names', []);

sub make_args {
	my ($class, @names) = @_;
	my $an = $class->Arg_Names;
	$class->Arg_Names([ @$an, @names ]);
}

__PACKAGE__->make_args(qw(default_value is_disabled is_trusted is_sealed));

sub arg {
	my ($self, $parent, $arg_name) = @_;
	my $fname = $self->name . "_$arg_name";
	return ($parent && exists $parent->{$fname}) ?
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

sub get_default_value {
	my ($self, $caller, $id) = @_;
	my $res = $self->arg($caller, "default_value");
	return defined($res)
			?  ref($res) eq 'CODE'
				? $res->($self, $id, $caller) : $res
			: '';
}

sub get_value {
	my ($self, $caller, $id) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	return defined($val) ? $val : $self->get_default_value($caller, $id);
}

sub seal_value {
	my ($self, $val) = @_;
	return HTML::Tested::Seal->instance->encrypt($val);
}

sub render {
	my ($self, $caller, $stash, $id) = @_;
	my $res = '';
	goto OUT if $self->arg($caller, "is_disabled");

	my $val = $self->get_value($caller, $id);
	if ($self->arg($caller, "is_sealed")) {
		$val = $self->seal_value($val);
	} elsif (!$self->arg($caller, "is_trusted")) {
		$val = $self->encode_value($val);
	}

	$res = $self->value_to_string($id, $val, $caller);
OUT:
	$stash->{ $self->name } = $res;
}

sub bless_from_tree { return $_[1]; }

sub absorb_one_value {
	my ($self, $root, $val, @path) = @_;
	$root->{ $self->name } = $self->arg(undef, "is_sealed")
		? HTML::Tested::Seal->instance->decrypt($val) : $val;
}

1;
