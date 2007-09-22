=head1 NAME

HTML::Tested - Provides HTML widgets with the built-in means of testing.

=head1 SYNOPSIS

    package MyPage;
    use base 'HTML::Tested';

    __PACKAGE__->make_tested_value('x');

    # Register my own widget
    __PACKAGE__->register_tested_widget('my_widget', 'My::App::Widget');
    __PACKAGE__->make_tested_my_widget('w');


    # Later, in the test for example
    package main;

    my $p = MyPage->construct_somehow;
    $p->x('Hi');
    my $stash = {};

    $p->ht_render($stash);

    # stash contains x => 'Hi'
    # We can pass it to templating mechanism

    # Stash checking function
    my @errors = HTML::Tested::Test->check_stash(
            'MyPage', $stash, { x => 'Hi' });

    # Stash checking function
    my @errors = HTML::Tested::Test->check_text(
            'MyPage', '<html>x</html>', { x => 'Hi' });

=head1 DISCLAIMER
	
This is pre-alpha quality software. Please use it on your own risk.

=head1 INTRODUCTION

Imagine common web programming scenario - you have HTML page packed with
checkboxes, edit boxes, labels etc.

You are probably using some kind of templating mechanism for this page already.
However, your generating routine still has quite a lot of complex code.

Now, being an experienced XP programmer, you face the task of writing test
code for the routine. Note, that your test code can deal with the results on
two levels: we can check the stash that we are going to pass to the templating module
or we can crawl our site and check the resulting text.

As you can imagine both of those scenarios require quite a lot of effort to
get right.

HTML::Tested can help here. It does this by generating stash data from the
widgets that you declare. Its testing code can check the existence of those
widgets both in the stash and in the text of the page.

=cut

use strict;
use warnings FATAL => 'all';

package HTML::Tested;
use base 'Class::Accessor', 'Class::Data::Inheritable', 'Exporter';
use Carp;
our $VERSION = 0.29;

our @EXPORT_OK = qw(HT HTV);

use constant HT => 'HTML::Tested';
use constant HTV => 'HTML::Tested::Value';

__PACKAGE__->mk_classdata('Widgets_List', []);

=head1 METHODS

=head2 $class->ht_add_widget($widget_class, $widget_name, @widget_args)

Adds widget implemented by C<$widget_class> to C<$class> as C<$widget_name>.
C<@widget_args> are passed as is into $widget_class->new function.

For example, A->ht_add_widget("HTML::Tested::Value", "a", default_value => "b");
will create value widget (and corresponding C<a> accessor) in A class which
will have default value "b".

=cut
sub ht_add_widget {
	my ($class1, $widget_class, $name, @args) = @_;
	$class1->mk_accessors($name);

	# The following will be simplified once deprecation is over...
	my $res = $widget_class->new($class1, $name, @args);

	# to avoid inheritance troubles...
	my @wl = @{ $class1->Widgets_List || [] };
	push @wl, $res;
	$class1->Widgets_List(\@wl);
	return $res;
}

=head2 ht_render(stash)

Renders all of the contained controls into the stash.
C<stash> should be hash reference.

=cut
sub ht_render {
	my ($self, $stash, $parent_name) = @_;
	for my $v (@{ $self->Widgets_List }) {
		my $n = $v->name;
		my $id = $parent_name ? $parent_name . "__$n" : $n;
		$v->render($self, $stash, $id);
	}
}

=head2 ht_find_widget($widget_name)

Finds widget named C<$widget_name>.

=cut
sub ht_find_widget {
	my ($self, $wn) = @_;
	my ($res) = grep { $_->name eq $wn } @{ $self->Widgets_List };
	return $res;
}

=head2 ht_bless_from_tree(class, tree)

Creates blessed instance of the class from tree.

=cut
sub ht_bless_from_tree {
	my ($class, $tree) = @_;
	my $res = {};
	while (my ($n, $v) = each %$tree) {
		my $wc = $class->ht_find_widget($n);
		$res->{$n} = $wc ? $wc->bless_from_tree($v) : $v;
	}
	return bless($res, $class);
}

sub ht_absorb_one_value {
	my ($self, $root, $val, @path) = @_;
	my $p = shift(@path) or return;
	my $wc = $self->ht_find_widget($p) or return;
	$wc->absorb_one_value($root, $val, @path);
}

=head2 ht_convert_request_to_tree(class, r)

Creates blessed instance of the class from Apache::Request
compatible object.

=cut
sub ht_convert_request_to_tree {
	my ($class, $r) = @_;
	my %args = ((map { ($_, $r->param($_)) } $r->param)
			, (map { ($_->name, $_) } $r->upload));
	my %res = (__ht_crqt_state => {});
	for my $k (sort keys %args) {
		$class->ht_absorb_one_value(\%res, 
				$args{$k}, split('__', $k));
	}
	delete $res{__ht_crqt_state};
	return bless(\%res, $class);
}

=head2 ht_get_widget_option($widget_name, $option_name)

Gets option C<$option_name> for widget named C<$widget_name>.

=cut
sub ht_get_widget_option {
	my ($self, $wname, $opname) = @_;
	my $w = $self->ht_find_widget($wname)
		or confess "Unknown widget $wname";
	if (ref($self)) {
		my $n = "__ht__$wname\_$opname";
		return $self->{$n} if exists $self->{$n};
	}
	return $w->options->{$opname};
}

=head2 ht_set_widget_option($widget_name, $option_name, $value)

Sets option C<$option_name> to C<$value> for widget named C<$widget_name>.

=cut
sub ht_set_widget_option {
	my ($self, $wname, $opname, $val) = @_;
	my $w = $self->ht_find_widget($wname)
		or confess "Unknown widget $wname";
	if (ref($self)) {
		$self->{"__ht__$wname\_$opname"} = $val;
	} else {
		$w->options->{$opname} = $val;
	}
}

=head2 $root->ht_validate

Recursively validates all contained widgets. See C<HTML::Tested::Value> for
C<$widget->validate> method description.

Prepends the names of the widgets which failed validation into result arrays.

=cut
sub ht_validate {
	my $self = shift;
	my @res;
	for my $v (@{ $self->Widgets_List }) {
		my $n = $v->name;
		push @res, map { [ $n, @$_ ] } $v->validate($self->$n, $self);
	}
	return @res;
}

=head2 $root->ht_make_query_string($uri, @widget_names)

Makes query string from $uri and widget values.

=cut
sub ht_make_query_string {
	my ($self, $uri, @widget_names) = @_;
	return "$uri?" . join("&", map {
		"$_=" . $self->ht_find_widget($_)->prepare_value($self, $_)
	} @widget_names);
}

1;

=head1 BUGS

Documentation is too sparse to be taken seriously.

=head1 AUTHOR

	Boris Sukholitko
	CPAN ID: BOSU
	
	boriss@gmail.com
	

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

HTML::Tested::Test for writing tests using HTML::Tested.
See HTML::Tested::Value::* for the documentation on the specific
widgets.
See HTML::Tested::List for documentation on list container.

=cut

