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

	my @renderers = ('HTML::Tested::List::Renderer');
	push @renderers, HTML::Tested::List::Table->new if $args{render_table};

	$args{renderers} ||= \@renderers;
	{
		no strict 'refs';
		*{ "$parent\::$name\_containee" } = sub { return $c; };
		*{ "$parent\::$name\_containee_do" } = sub {
			my ($self, $func, @args) = @_;
			return $self->$name($c->$func(@args));
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
	$arr->[--$id] ||= bless({}, $self->containee);
	$self->containee->ht_absorb_one_value($arr->[$id], $val, @path);
	$root->{ $self->name } = $arr;
}

sub finish_load {
	my ($self, $root) = @_;
	my $arr = $root->{ $self->name };
	$root->{ $self->name } = [ grep { $_ } @$arr ];
}

sub validate {
	my ($self, $arr) = @_;
	return map { ($_->ht_validate) } (@{ $arr || [] });
}

1;

