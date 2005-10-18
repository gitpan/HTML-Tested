use strict;
use warnings FATAL => 'all';

package HTML::Tested::Value::Tree;

sub _render_from_selection_tree {
	my ($self, $context, $nodes, $sel_tree, $ident) = @_;
	my $res = "$ident<ul>\n";
	for my $n (@$nodes) {
		my $n_sel = $sel_tree->{ $n->{ $context->{selection_attribute} } };
		my $new_ident = "$ident  ";
		$res .= "$new_ident<li>\n";
		if ($n_sel) {
			$res .= $self->_render_selected_node(
					$context, $n, "$new_ident  ");
			$res .= $self->_render_from_selection_tree(
					$context, $n->{children}, $n_sel, 
					"$ident    ") if $n->{children};
		} else {
			$res .=	$self->_render_collapsed_node(
					$context, $n, "$new_ident  ");
		}
		$res .= "$new_ident</li>\n";
	}
	return $res . "$ident</ul>\n";
}

sub _build_selection_tree {
	my ($self, $nodes, $selections, $sel_attr) = @_;
	my $tree = {};
	for my $n (@$nodes) {
		my $v = $n->{$sel_attr};
		my $nt = {};
		if (my $c = $n->{children}) {
			$nt = $self->_build_selection_tree(
						$c, $selections, $sel_attr);
		}
		next unless (%$nt || $selections->{$v});
		$tree->{$v} = $nt;
	}
	return $tree;
}

sub value_to_string {
	my ($self, $name, $val) = @_;
	my $tree = $val->{selection_tree} 
			|| $self->_build_selection_tree($val->{input_tree}
				, { map { ($_, 1) } @{ $val->{selections} } }
				, $val->{selection_attribute});
	return $self->_render_from_selection_tree($val, $val->{input_tree}, 
			$tree, '');
}

sub _render_from_format {
	my ($self, $format, $node, $ident) = @_;
	my $res = $ident . $format . "\n";
	while (my ($n, $v) = each %$node) {
		$res =~ s/\%$n\%/$v/g;
	}
	return $res;
}

sub _render_selected_node {
	my ($self, $context, $node, $ident) = @_;
	return $self->_render_from_format($context->{selected_format}
			|| '<span class="selected">%value%</span>', $node, $ident);
}

sub _render_collapsed_node {
	my ($self, $context, $node, $ident) = @_;
	return $self->_render_from_format($context->{collapsed_format}
			|| '<a href="#">%value%</a>', $node, $ident);
}

1;
