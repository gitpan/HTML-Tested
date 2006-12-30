=head1 NAME

HTML::Tested::Value - Base class for most HTML::Tested widgets.

=head1 DESCRIPTION

This class provides the most basic HTML::Tested widget - simple value to be output in
the template.

=head1 METHODS

=cut

use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value;
use HTML::Entities;
use HTML::Tested::Seal;
use Carp;

sub new {
	my ($class, $parent, $name, %opts) = @_;
	my $self = bless({ name => $name, _options => \%opts
			, constraints => [], validators => [] }, $class);
	my $cs = $opts{constraints} || [];
	$self->push_constraint($_) for @$cs;
	return $self;
}

=head2 $widget->name

Returns name of the widget.

=cut
sub name { return shift()->{name}; }
sub options { return shift()->{_options}; }

sub value_to_string {
	my ($self, $name, $val) = @_;
	return $val;
}

sub encode_value {
	my ($self, $val) = @_;
	die "Non scalar value $val" if ref($val);
	return encode_entities($val, '<>&"');
}

sub get_default_value {
	my ($self, $caller, $id) = @_;
	my $res = $caller->ht_get_widget_option(
			$self->name, "default_value");
	return defined($res)
			?  ref($res) eq 'CODE'
				? $res->($self, $id, $caller) : $res
			: '';
}

=head2 $widget->get_value($caller, $id)

It is called from $widget->render to get the value to render.

=cut
sub get_value {
	my ($self, $caller, $id) = @_;
	my $n = $self->name;
	my $val = $caller->$n;
	return defined($val) ? $val : $self->get_default_value($caller, $id);
}

=head2 $widget->seal_value($value)

It is called from $widget->render to seal the value before putting it to stash.
See HTML::Tested::Seal for sealing functionality.

=cut
sub seal_value {
	my ($self, $val) = @_;
	return HTML::Tested::Seal->instance->encrypt($val);
}

=head2 $widget->render($caller, $stash, $id)

Renders widget into $stash. For HTML::Tested::Value it essentially means
assigning $stash->{ $widget->name } with $widget->get_value.

=cut
sub render {
	my ($self, $caller, $stash, $id) = @_;
	my $res = '';
	my $n = $self->name;
	goto OUT if $caller->ht_get_widget_option($n, "is_disabled");

	my $val = $self->get_value($caller, $id);
	$val = $self->seal_value($val, $caller)
		if $caller->ht_get_widget_option($n, "is_sealed");

	$val = $self->encode_value($val, $caller)
		unless $caller->ht_get_widget_option($n, "is_trusted");

	$res = $self->value_to_string($id, $val, $caller);
OUT:
	$stash->{$n} = $res;
}

sub bless_from_tree { return $_[1]; }

=head2 $widget->push_constraint($constraint)

C<$constraint> should be ARRAY reference with the following format:

[ TYPE, OP, COOKIE ]

where C<TYPE> is type of the constraint, C<OP> is the operation to be done on
the constraint and cookie is optional method for the application to recognize
specific constraint.

Available types are:
C<regexp> - with OP being regexp string (e.g. [ regexp => '\d+' ].
C<defined> - C<OP> doesn't matter here (e.g. [ defined => '' ].

=cut
sub push_constraint {
	my ($self, $c) = @_;
	my $func;
	push @{ $self->{constraints} }, $c;
	confess "Constraint should be of [ TYPE, OP ] format"
			unless ($c && ref($c) eq 'ARRAY');
	if ($c->[0] eq 'regexp') {
		my $rexp = $c->[1];
		$func = sub {
			my $v = shift;
			return defined($v) ? $v =~ /$rexp/ : undef;
		};
	} elsif ($c->[0] eq 'defined') {
		$func = sub { return defined($_[0]); };
	} else {
		confess "Unknown type " . $c->[0] . " found!\n";
	}
	push @{ $self->{validators} }, $func if $func;
}

=head2 $widget->validate($value)

Validate value returning list of failed constraints in the format specified above.
I.e. the C<$value> is "constraint-clean" when C<validate> returns empty list.

=cut
sub validate {
	my ($self, $val) = @_;;
	my $vs = $self->{validators};
	my @res;
	for (my $i = 0; $i < @$vs; $i++) {
		next if $vs->[$i]->($val);
		push @res, $self->{constraints}->[$i];
	}
	return @res;
}

=head2 $widget->absorb_one_value($parent, $val, @path)

Parses C<$val> and puts the result into C<$parent> object. C<@path> is used for
widgets aggregating other widgets (such as C<HTML::Tested::List>).

=cut
sub absorb_one_value {
	my ($self, $root, $val, @path) = @_;
	$root->{ $self->name } = (
		$self->options->{"is_sealed"}
		? HTML::Tested::Seal->instance->decrypt($val) : $val);
}

1;

=head1 AUTHOR

	Boris Sukholitko (boriss@gmail.com)
	
=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

HTML::Tested

=cut

