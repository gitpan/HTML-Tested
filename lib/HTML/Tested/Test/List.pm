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

sub _check_stash {
	my ($class, $w_class, $n, $res, $expected) = @_;
	my @err;
	for (my $i = 0; $i < @$res || $i < @$expected; $i++) {
		push @err, HTML::Tested::Test->compare_stashes(
				$w_class->containee->Widgets_Map, 
				$res->[$i], $expected->[$i]);
	}
	return @err;
};

sub _check_text {
	my ($class, $w_class, $n, $text, $expected) = @_;
	my @err;
	for (my $i = 0; $i < @$expected; $i++) {
		push @err, HTML::Tested::Test->compare_text_to_stash(
				$w_class->containee->Widgets_Map, 
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
	HTML::Tested::Test::List::Blesser->convert_tree_to_param($target, $r, $_,
				$name . "__" . $_->{ht_id})
		for @$val;
}

1;
