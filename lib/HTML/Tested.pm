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

HTML::Tested can help here. It does this by generating stash data from the widgets
that you declare. Its testing code can check the existence of those widgets both in
the stash and in the text of the page.

=cut

use strict;
use warnings FATAL => 'all';

package HTML::Tested;
use base 'Class::Accessor', 'Class::Data::Inheritable';
use Carp;
our $VERSION = 0.07;

__PACKAGE__->mk_classdata('Widgets_Map');

=head1 METHODS

=head2 register_tested_widget(widget_name, widget_class, dont_use)

Registers widget to be available for the inheriting classes.
This implicitly creates make_tested_<widget_name> function.
C<widget_class> should provide behind the scenes support for the widget.
C<dont_use> tells HTML::Tested to not use the module at the time of
loading.

=cut

sub register_tested_widget {
	my ($class, $widget_name, $widget_class, $dont_use) = @_;
	no strict 'refs';
	*{ "$class\::make_tested_$widget_name" } = sub {
		my ($class1, $name, @args) = @_;
		unless ($dont_use) {
			eval "use $widget_class";
			confess "Error using $widget_class: $@" if $@;
		}
		$class1->Widgets_Map({}) unless $class1->Widgets_Map;
		$class1->mk_accessors($name);
		$class1->Widgets_Map->{$name} = 
			$widget_class->new($class1, $name, @args);
	};
}

=head2 ht_render(stash)

Renders all of the contained controls into the stash.
C<stash> should be hash reference.

=cut
sub ht_render {
	my ($self, $stash, $parent_name) = @_;
	while (my ($n, $v) = each %{ $self->Widgets_Map }) {
		my $id = $parent_name ? $parent_name . "__$n" : $n;
		$v->render($self, $stash, $id);
	}
}


=head2 ht_bless_from_tree(class, tree)

Creates blessed instance of the class from tree.

=cut
sub ht_bless_from_tree {
	my ($class, $tree) = @_;
	my $res = {};
	while (my ($n, $v) = each %$tree) {
		my $wc = $class->Widgets_Map->{$n};
		$res->{$n} = $wc ? $wc->bless_from_tree($v) : $v;
	}
	return bless($res, $class);
}

sub ht_absorb_one_value {
	my ($self, $root, $val, @path) = @_;
	my $p = shift(@path) or return;
	if (@path) {
		my $wc = $self->Widgets_Map->{$p} or return;
		my $ab = $wc->can('absorb_one_value') or return;
		$root->{$p} = $ab->($wc, $root->{$p}, $val, @path);
	} else {
		$root->{$p} = $val;
	}
}

=head2 ht_convert_request_to_tree(class, r)

Creates blessed instance of the class from Apache::Request
compatible object.

=cut
sub ht_convert_request_to_tree {
	my ($class, $r) = @_;
	my @pkeys = $r->param;
	my %res;
	for my $p (sort @pkeys) {
		$class->ht_absorb_one_value(\%res, 
				$r->param($p), split('__', $p));
	}
	return bless(\%res, $class);
}

__PACKAGE__->register_tested_widget('value', 'HTML::Tested::Value');
__PACKAGE__->register_tested_widget('marked_value', 'HTML::Tested::Value::Marked');
__PACKAGE__->register_tested_widget('edit_box', 'HTML::Tested::Value::EditBox');
__PACKAGE__->register_tested_widget(
		'textarea', 'HTML::Tested::Value::TextArea');
__PACKAGE__->register_tested_widget(
		'password_box', 'HTML::Tested::Value::PasswordBox');
__PACKAGE__->register_tested_widget(
		'dropdown', 'HTML::Tested::Value::DropDown');
__PACKAGE__->register_tested_widget(
		'checkbox', 'HTML::Tested::Value::CheckBox');

__PACKAGE__->register_tested_widget('list', 'HTML::Tested::List');

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

