use strict;
use warnings FATAL => 'all';

package HTML::Tested::List;
use HTML::Tested::List::Renderer;
use HTML::Tested::List::Table;
use Carp;

sub new {
	my ($class, $parent, $name, $c, %args) = @_;
	$args{containee} ||= $c;
	$args{name} ||= $name;
	$args{renderers} ||= [ 'HTML::Tested::List::Renderer'
		, 'HTML::Tested::List::Table' ];
	{
		no strict 'refs';
		*{ "$parent\::$name\_containee" } = sub { return $c; };
		*{ "$parent\::$name\_containee_do" } = sub {
			my ($self, $func, @args) = @_;
			$self->$name($c->$func(@args));
		};
	};
	
	my $self = bless(\%args, $class);
	for my $r (@{ $self->renderers }) {
		$r->init($self, $parent);
	}
	return $self;
}

sub name { return shift()->{name}; }
sub renderers { return shift()->{renderers}; }
sub options { return {}; }

sub render {
	my ($self, $caller, $stash, $id) = @_;
	for my $r (@{ $self->renderers }) {
		$r->render($self, $caller, $stash, $id);
	}
}

sub containee {
	my $res = shift()->{containee}
		or confess "No containee argument given";
	return $res;
}

sub bless_from_tree {
	my ($self, $p) = @_;
	my $target = $self->containee;
	return [ map { $target->ht_bless_from_tree($_) } @$p ];
}

sub absorb_one_value {
	my ($self, $root, $val, @path) = @_;
	my $arr = $root->{ $self->name } || [];
	my $id = shift(@path) or return;
	my $last = $arr->[ @$arr - 1 ];
	if (!$last || $root->{__ht_crqt_state}->{ $self->name } ne $id) {
		$root->{__ht_crqt_state}->{ $self->name } = $id;
		$last = bless({}, $self->containee);
		push @$arr, $last;
	}
	$self->containee->ht_absorb_one_value($last, $val, @path);
	$root->{ $self->name } = $arr;
}

1;

