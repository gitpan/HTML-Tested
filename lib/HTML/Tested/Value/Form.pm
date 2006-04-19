use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Form;
use base 'HTML::Tested::Value';

sub run_validators {
	my ($self, $parent) = @_;
	my @res;
	for my $c (@{ $self->{children} }) {
		my $vs = $c->{validators} or next;
		my $f = $c->name;
		my $val = $parent->$f;
		$val = '' unless defined($val);
		for my $v (@$vs) {
			next if $v->[1]->($val);
			push @res, $f, $v->[0];
		}
	}
	return @res;
}

sub Push_Constraints {
	my $ctrl = shift;
	my @res;
	for my $c (@_) {
		my $func;
		if ($c =~ /^\/(.+)\/$/) {
			my $rexp = $1;
			$func = sub {
				return shift() =~ /$rexp/;
			};
		}
		push @res, [ $c, $func ] if $func;
	}
	if (my $arr = $ctrl->{validators}) {
		push @$arr, @res;
	} else {
		$ctrl->{validators} = \@res;
	}
}

sub new {
	my $self = shift()->SUPER::new(@_);
	my $parent = shift;
	my $children = $self->args->{children} || [];
	my @parsed_children;
	while (my ($n, $type, $args) = splice(@$children , 0, 3)) {
		my $f = "make_tested_$type";
		if (!ref($args)) {
			unshift @$children, $args if $args;
			$args = {};
		}
		my $control = $parent->$f($n, %$args);
		push @parsed_children, $control;
		my $cs = $args->{constraints} or next;
		Push_Constraints($control, @$cs)
	}

	$self->{children} = \@parsed_children;
	no strict 'refs';
	*{ $parent . "::validate_" . $self->name } = sub {
		return $self->run_validators(shift());
	};
	return $self;
}

sub aggregate_validators {
	my $self = shift;
	my @res;
	for my $c (@{ $self->{children} }) {
		my $vs = $c->{validators} or next;
		push @res, map { [ $c->name, $_->[0], $_->[1] ] } @$vs;
	}
	return @res;
}

sub value_to_string {
	my ($self, $name, $val) = @_;
	my $res = "<form id=\"$name\" name=\"$name\" method=\"post\""
			. " action=\"$val\"";
	my @vals = $self->aggregate_validators or return "$res>\n";
	$res .= " onsubmit=\"return validate_$name(this)\">\n";
	$res = "<script language=\"javascript\">\n"
		. "function validate_$name(form) {\n\treturn "
		. join("\n\t\t&& ", map {
			"validate(form, '$_->[0]', $_->[1])"
		} @vals) . ";\n}\n</script>\n$res";
	return $res;
}

1;
