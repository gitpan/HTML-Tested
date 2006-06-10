use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::Radio;
use base 'HTML::Tested::Test::Value';

sub _opts {
	my ($class, $name, $e_self) = @_;
	my @res;
	my $e_opts = $e_self->$name or return ();
	return map { "$name\_$_" } map { ref($_) ? $_->[0] : $_; } @$e_opts;
}

sub check_stash {
	my ($class, $w_class, $e_stash, $r_stash, $name, $e_self) = @_;
	my @err;
	for my $n ($class->_opts($name, $e_self)) {
		my $e_val = $e_stash->{$n};
		my $r_val = HTML::Tested::Test::Ensure_Value_To_Check(
				$r_stash, $n, $e_val, \@err);
		next unless defined($r_val);
		next if ($r_val eq $e_val);
		push @err, HTML::Tested::Test::Stash_Mismatch(
				$n, $r_val, $e_val);
	}
	return @err;
}

sub check_text {
	my ($class, $widget, $e_stash, $text, $name, $e_self) = @_;
	return map { $class->_check_text_i($widget, $text, $e_stash->{$_}) }
				$class->_opts($name, $e_self);
}

1;
