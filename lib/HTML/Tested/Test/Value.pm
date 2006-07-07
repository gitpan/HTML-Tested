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
		$r = 'ENCRYPTED' unless defined($r);
		$val =~ s/$found/$r/;
	}
	return $val;
}

sub _handle_sealed {
	my ($class, $e_root, $name, $e_val, $r_val, $err) = @_;
	if ($e_root->{"__HT_SEALED__$name"}) {
		my $orig_e_val = $e_val;
		$e_val = $class->_replace_sealed($e_val);
		$r_val = $class->_replace_sealed($r_val);

		push @$err, "$name wasn't sealed" if ($orig_e_val eq $e_val);
	} elsif ($e_root->ht_get_widget_option($name, "is_sealed")) {
		push @$err, "HT_SEALED was not defined on $name";
	}
	return ($e_val, $r_val);
}

sub check_stash {
	my ($class, $e_root, $name, $e_stash, $r_stash) = @_;
	my @err;
	goto OUT unless exists($e_stash->{$name});

	my $e_val = $e_stash->{$name};
	my $r_val = HTML::Tested::Test::Ensure_Value_To_Check(
			$r_stash, $name, $e_val, \@err);
	goto OUT unless defined($r_val);

	($e_val, $r_val) = $class->_handle_sealed($e_root, $name
					, $e_val, $r_val, \@err);
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
	my ($class, $e_root, $name, $v, $text) = @_;
	my @ret;
	($v, $text) = $class->_handle_sealed($e_root, $name, $v
					     , $text, \@ret);

	if ($e_root->{"__HT_REVERTED__$name"}) {
		@ret = ("Unexpectedly found \"$v\" in \"$text\"")
			if (index($text, $v) != -1);
	} elsif (index($text, $v) == -1) {
		@ret = ("Unable to find \"$v\" in \"$text\"");
	}
	return @ret;
}

sub check_text {
	my ($class, $e_root, $name, $e_stash, $text) = @_;
	return $class->_check_text_i($e_root, $name,
			, $e_stash->{$name}, $text);
}

sub _convert_to_param {
	my ($class, $obj_class, $r, $name, $val) = @_;
	$r->param($name, $val);
}

1;
