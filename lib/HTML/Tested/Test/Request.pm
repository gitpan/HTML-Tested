use strict;
use warnings FATAL => 'all';

package HTML::Tested::Test::Request::Upload;
use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw(name filename fh));

package HTML::Tested::Test::Request;
use base 'Class::Accessor';
use HTML::Tested::Seal;
use Data::Dumper;
use File::Basename qw(basename);

__PACKAGE__->mk_accessors(qw(_param _pnotes _uploads));

sub server_root_relative {
	return $_[1];
}

sub param {
	my ($self, $name, $val) = @_;
	$self->_param({}) unless $self->_param;
	$self->_param->{$name} = $val if (defined($val));
	return $self->_param->{$name} if ($name);
	return keys %{ $self->_param || {} };
}

sub dir_config {
	return '';
}

sub set_params {
	my ($self, $p) = @_;
	while (my ($n, $v) = each %$p) {
		$v = HTML::Tested::Seal->instance->encrypt($v)
				if ($n =~ s/^HT_SEALED_//);
		$self->param($n, $v);
	}
}

sub parse_url {
	my ($self, $url) = @_;
	my ($arg_str) = ($url =~ /\?(.+)/);
	return unless $arg_str;
	my @nvs = split('&', $arg_str);
	my %res = map {
		my @a = split('=', $_);
		($a[0], ($a[1] || ''));
	} @nvs;
	$self->_param(\%res);
}

sub pnotes {
	my ($self, $name, $val) = @_;
	$self->_pnotes({}) unless $self->_pnotes;
	return $self->_pnotes->{$name} unless scalar(@_) > 2;
	$self->_pnotes->{$name} = $val;
}

sub add_upload {
	my ($self, $n, $v) = @_;
	$self->_uploads([]) unless $self->_uploads;
	open(my $fh, $v) or die "Unable to open $v";
	push @{ $self->_uploads }, HTML::Tested::Test::Request::Upload->new({
			name => $n, filename => basename($v) , fh => $fh });
}

sub upload {
	my ($self, $n) = @_;
	my $ups = $self->_uploads || [];
	return $n ? (grep { $_->name eq $n } @$ups)[0] : @$ups;
}

sub as_string {
	return Dumper(shift());
}

1;
