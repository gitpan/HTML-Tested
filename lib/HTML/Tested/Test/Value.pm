use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::Value;

sub _check_stash {
	my ($class, $w_class, $n, $res, $v) = @_;
	return ($res eq $v) ? () : HTML::Tested::Test::Stash_Mismatch($n, $res, $v);
};

sub bless_from_tree {
	my $class = shift;
	return shift()->bless_from_tree(@_);
}

sub _check_text {
	my ($class, $widget, $n, $text, $v) = @_;
	return (index($text, $v) == -1) 
			? ("Unable to find \"$v\" in \"$text\"") : ();
}

sub _convert_to_param {
	my ($class, $obj_class, $r, $name, $val) = @_;
	$r->param($name, $val);
}

1;
