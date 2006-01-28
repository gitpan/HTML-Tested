use strict;
use warnings FATAL => 'all';

package HTML::Tested::List;
use HTML::Tested::List::Renderer;
use Carp;

sub new {
	my ($class, $parent, $name, $c, %args) = @_;
	$args{containee} ||= $c;
	$args{name} ||= $name;
	$args{renderers} ||= [ 'HTML::Tested::List::Renderer' ];
	{
		no strict 'refs';
		*{ "$parent\::$name\_containee" } = sub { return $c; };
	};
	
	my $self = bless(\%args, $class);
	for my $r (@{ $self->renderers }) {
		$r->init($self, $parent);
	}
	return $self;
}

sub name { return shift()->{name}; }
sub renderers { return shift()->{renderers}; }

sub render {
	my ($self, $caller, $stash, $id) = @_;
	for my $r (@{ $self->renderers }) {
		$r->render($self, $caller, $stash, $id);
	}
}

sub containee {
	my $res = shift()->{containee} or confess "No containee argument given";
	return $res;
}

sub bless_from_tree {
	my ($self, $p) = @_;
	my $target = $self->containee;
	return [ map { $target->ht_bless_from_tree($_) } @$p ];
}

sub absorb_one_value {
	my ($self, $arr, $val, @path) = @_;
	my $id = shift(@path) or return;
	my $c = bless({ ht_id => $id }, $self->containee);
	if ($arr) {
		if ($arr->[ @$arr - 1 ]->{ht_id} ne $id) {
			push @$arr, $c;
		}
	} else {
		$arr = [ $c ];
	}
	$self->containee->ht_absorb_one_value($arr->[ @$arr - 1 ], $val, @path);
	return $arr;
}

1;

