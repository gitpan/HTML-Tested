use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::List::Blesser;
use base 'HTML::Tested::Test';

sub bless_unknown_widget {
	my ($class, $n, $v, $err) = @_;
	return $v if $n eq 'ht_id';
	return $class->SUPER::bless_unknown_widget($n, $v, $err);
}

sub _tree_to_param_fallback {
	my ($class, $n) = @_;
	return if $n eq 'ht_id';
	return $class->SUPER::_tree_to_param_fallback($n);
}

package HTML::Tested::Test::List;

sub check_stash {
	my ($class, $widget, $e_stash, $r_stash, $name) = @_;
	my @err;
	goto OUT unless exists($e_stash->{$name});

	my $e_arr = $e_stash->{$name};
	my $r_arr = HTML::Tested::Test::Ensure_Value_To_Check(
			$r_stash, $name, $e_arr, \@err);
	goto OUT unless defined($r_arr);

	for (my $i = 0; $i < @$r_arr || $i < @$e_arr; $i++) {
		push @err, HTML::Tested::Test->compare_stashes(
				$widget->containee, 
				$r_arr->[$i], $e_arr->[$i]);
	}
OUT:
	return @err;
};

sub check_text {
	my ($class, $widget, $e_stash, $text, $name) = @_;
	return () unless exists $e_stash->{$name};
	my $expected = $e_stash->{$name};
	my @err;
	for (my $i = 0; $i < @$expected; $i++) {
		push @err, HTML::Tested::Test->compare_text_to_stash(
				$widget->containee, 
				$text, $expected->[$i]);
	}
	return @err;
}

sub bless_from_tree {
	my ($class, $w_class, $p, $err) = @_;
	my $target = $w_class->containee;
	return [ map { HTML::Tested::Test::List::Blesser
				->bless_from_tree_for_test($target, $_, $err);
	} @$p ];
}

sub _convert_to_param {
	my ($class, $obj_class, $r, $name, $val) = @_;
	my $target = $obj_class->containee;
	while (my ($id, $fields) = splice(@$val, 0, 2)) {
		HTML::Tested::Test::List::Blesser->convert_tree_to_param(
				$target, $r, $fields, $name . "__$id");
	}
}

1;
