use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test;
use Data::Dumper;
use Carp;

sub Stash_Mismatch {
	my ($n, $res, $v) = @_;
	return sprintf("Mismatch at %s: got %s, expected %s",
				$n, defined($res) ? "\"$res\"" : "undef",
				defined($v) ? "\"$v\"" : "undef");
}

sub Ensure_Value_To_Check {
	my ($r_stash, $name, $e_val, $errs) = @_;
	my $r_val = $r_stash->{$name};
	return if (!defined($r_val) && !defined($e_val));

	if (defined($r_val) xor defined($e_val)) {
		push @$errs, Stash_Mismatch($name, $r_val, $e_val);
		return;
	}
	return $r_val;
}

sub compare_stashes {
	my ($class, $e_root, $stash, $e_stash) = @_;
	return () if (!defined($stash) && !defined($e_stash));
	if (defined($stash) xor defined($e_stash)) {
		return ("Stash " . Dumper($stash)
				. "differ from "
				. "expected " . Dumper($e_stash));
	}

	my $widgets_map = $e_root->Widgets_Map;
	return $class->_run_checks('stash', $e_root, $stash, $e_stash);
}

sub _run_checks {
	my ($class, $check, $e_root, $res, $e_stash) = @_;
	my $widgets_map = $e_root->Widgets_Map;
	my $f = "check_$check";
	my @res;
	while (my ($n, $w) = each %$widgets_map) {
		push @res, $w->__ht_tester->$f($e_root, $n, $e_stash, $res);
	}
	return @res;
}

sub compare_text_to_stash {
	my ($class, $e_root, $text, $e_stash) = @_;
	return $class->_run_checks('text', $e_root, $text, $e_stash);
}

my $_index = 0;

sub Make_Expected_Class {
	my ($target_class, $expected) = @_;
	my $package = "$target_class\::__HT_TESTER_" . $_index++;
	{ 
		no strict 'refs';
		push @{ *{ "$package\::ISA" } }, $target_class 
			unless @{ *{ "$package\::ISA" } };
	};
	my $widgets_map = $target_class->Widgets_Map;
	my %new_map;
	for my $k (keys %$widgets_map) {
		$new_map{$k} = $widgets_map->{$k} if exists($expected->{$k});
	}
	$package->Widgets_Map(\%new_map);
	return $package;
}

sub bless_unknown_widget {
	my ($class, $n, $v, $err) = @_;
	push @$err, "Unknown widget $n found in expected!";
	return $v;
}
	 
sub bless_from_tree_for_test {
	my ($class, $target, $expected, $err) = @_;
	my $res = {};
	my (@disabled, %e, @reverted, @sealed);
	while (my ($n, $v) = each %$expected) {
		push @reverted, $n if ($n =~ s/^HT_NO_//);
		push @sealed, $n if ($n =~ s/^HT_SEALED_//);
		$e{$n} = $v;
	}
	$expected = \%e;

	my $e_class = Make_Expected_Class($target, $expected);
	while (my ($n, $v) = each %$expected) {
		if (defined($v) && $v eq 'HT_DISABLED') {
			push @disabled, $n;
			next;
		}
		my $wc = $e_class->Widgets_Map->{$n};
		$res->{$n} = $wc ?
			$wc->__ht_tester->bless_from_tree($wc, $v, $err)
			: $class->bless_unknown_widget($n, $v, $err);
	}
	my $e_root = bless($res, $e_class);
	$e_root->ht_set_widget_option($_, "is_disabled", 1) for @disabled;
	$e_root->{"__HT_REVERTED__$_"} = 1 for @reverted;
	$e_root->{"__HT_SEALED__$_"} = 1 for @sealed;
	return $e_root;
}

sub do_comparison {
	my ($class, $compare, $obj_class, $stash, $expected) = @_;
	my $e_stash = {};
	my @res;
	my $e_root = $class->bless_from_tree_for_test($obj_class
			, $expected, \@res);
	$e_root->ht_render($e_stash);

	push @res, $class->$compare($e_root, $stash, $e_stash);
	return @res;
}

sub check_stash { return shift()->do_comparison('compare_stashes', @_); }
sub check_text {
	return shift()->do_comparison('compare_text_to_stash', @_);
}

sub register_widget_tester {
	my ($class, $w_class, $t_class) = @_;
	eval "use $t_class";
	die "Cannot use $t_class: $@" if $@;
	no strict 'refs';
	*{ "$w_class\::__ht_tester" } = sub { return $t_class; };
}

sub _tree_to_param_fallback {
	my ($class, $n) = @_;
	confess "Unable to find widget for $n";
}

sub convert_tree_to_param {
	my ($class, $obj_class, $r, $tree, $parent_name) = @_;
	while (my ($n, $v) = each %$tree) {
		$v = HTML::Tested::Seal->instance->encrypt($v)
			if ($n =~ s/^HT_SEALED_//);
		my $wc = $obj_class->Widgets_Map->{$n};
		if ($wc) {
			$wc->__ht_tester->_convert_to_param($wc, $r, 
				$parent_name ? $parent_name . "__$n" : $n
				, $v);
		} else {
			$class->_tree_to_param_fallback($n);
		}
	}
}

__PACKAGE__->register_widget_tester('HTML::Tested::Value', 
		'HTML::Tested::Test::Value');
__PACKAGE__->register_widget_tester('HTML::Tested::Value::Radio', 
		'HTML::Tested::Test::Radio');
__PACKAGE__->register_widget_tester('HTML::Tested::List'
		, 'HTML::Tested::Test::List');

1;
