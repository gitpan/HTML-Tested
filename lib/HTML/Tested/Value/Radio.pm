use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Radio;
use base 'HTML::Tested::Value';

sub _make_radio {
	my ($ctl, $ctl_id, $caller) = @_;
	my $name = $ctl->{_radio_name};
	my $value = $ctl->{_radio_value};
	$ctl_id =~ s/_$value$//;
	my $r = $caller->$name;
	my $ch = defined($r) && $r eq $value ? "checked />" : "/>";
	return <<ENDS
<input type="radio" name="$ctl_id" id="$name" value="$value" $ch
ENDS
}

sub new {
	my ($class, $parent, $name, %args) = @_;
	my $self = $class->SUPER::new($parent, $name, %args);
	for my $ch (@{ $args{choices} }) {
		my $c = $parent->make_tested_value("$name\_$ch"
				, is_trusted => 1
				, default_value => \&_make_radio);
		$c->{_radio_name} = $name;
		$c->{_radio_value} = $ch;
	}
	return $self;
}

sub render {}

1;

