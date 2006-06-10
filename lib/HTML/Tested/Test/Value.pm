use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::Value;

my $_seal_prefix;

sub _replace_sealed {
	my ($class, $val) = @_;
	if (!$_seal_prefix) {
		my $s = HTML::Tested::Seal->instance->encrypt('aaa');
		$_seal_prefix = substr($s, 0, 7);
	}
	while ($val =~ /($_seal_prefix\w+)/g) {
		my $found = $1;
		my $r = HTML::Tested::Seal->instance->decrypt($found);
		$val =~ s/$found/$r/;
	}
	return $val;
}

sub check_stash {
	my ($class, $widget, $e_stash, $r_stash, $name) = @_;
	my @err;
	goto OUT unless exists($e_stash->{$name});

	my $e_val = $e_stash->{$name};
	my $r_val = HTML::Tested::Test::Ensure_Value_To_Check(
			$r_stash, $name, $e_val, \@err);
	goto OUT unless defined($r_val);

	if ($widget->arg(undef, "is_sealed")) {
		$e_val = $class->_replace_sealed($e_val);
		$r_val = $class->_replace_sealed($r_val);
	}

	goto OUT if ($r_val eq $e_val);

	@err = HTML::Tested::Test::Stash_Mismatch($name, $r_val, $e_val);
OUT:
	return @err;
}

sub bless_from_tree {
	my $class = shift;
	return shift()->bless_from_tree(@_);
}

sub _check_text_i {
	my ($class, $widget, $text, $v) = @_;
	if ($widget->arg(undef, "is_sealed")) {
		$text = $class->_replace_sealed($text)
			unless index($text, $_seal_prefix) == -1;
		$v = $class->_replace_sealed($v);
	}

	my @ret;
	if ($widget->{__HT_REVERTED__}) {
		@ret = ("Unexpectedly found \"$v\" in \"$text\"")
			if (index($text, $v) != -1);
	} elsif (index($text, $v) == -1) {
		@ret = ("Unable to find \"$v\" in \"$text\"");
	}
	return @ret;
}

sub check_text {
	my ($class, $widget, $e_stash, $text, $name) = @_;
	return () unless exists $e_stash->{$name};
	return $class->_check_text_i($widget, $text, $e_stash->{$name});
}

sub _convert_to_param {
	my ($class, $obj_class, $r, $name, $val) = @_;
	$r->param($name, $val);
}

1;
