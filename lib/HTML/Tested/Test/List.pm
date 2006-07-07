use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::List;

sub check_stash {
	my ($class, $e_root, $name, $e_stash, $r_stash) = @_;
	my @err;
	goto OUT unless exists($e_stash->{$name});

	my $e_arr = $e_stash->{$name};
	my $r_arr = HTML::Tested::Test::Ensure_Value_To_Check(
			$r_stash, $name, $e_arr, \@err);
	goto OUT unless defined($r_arr);

	for (my $i = 0; $i < @$r_arr || $i < @$e_arr; $i++) {
		push @err, HTML::Tested::Test->compare_stashes(
				$e_root->$name->[$i],
				$r_arr->[$i], $e_arr->[$i]);
	}
OUT:
	return @err;
};

sub check_text {
	my ($class, $e_root, $name, $e_stash, $text) = @_;
	return () unless exists $e_stash->{$name};
	my $expected = $e_stash->{$name};
	my @err;
	for (my $i = 0; $i < @$expected; $i++) {
		push @err, HTML::Tested::Test->compare_text_to_stash(
				$e_root->$name->[$i],
				$text, $expected->[$i]);
	}
	return @err;
}

sub bless_from_tree {
	my ($class, $w_class, $p, $err) = @_;
	my $target = $w_class->containee;
	return [ map {
		HTML::Tested::Test->bless_from_tree_for_test($target
				, $_, $err);
	} @$p ];
}

sub _convert_to_param {
	my ($class, $obj_class, $r, $name, $val) = @_;
	my $c = $obj_class->containee;
	HTML::Tested::Test->convert_tree_to_param(
		$c, $r, $val->[$_ - 1], $name . "__$_") for (1 .. @$val);
}

1;
