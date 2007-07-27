use strict;
use warnings FATAL => 'all';

package HTML::Tested::Seal;
use base 'Class::Singleton';
use Crypt::CBC;
use Digest::CRC qw(crc32);
use Carp;

our $Cache;

sub _new_instance {
	my ($class, $key) = @_;
	my $self = bless({}, $class);
	confess "No key!" unless $key;
	my $c = Crypt::CBC->new({ key => $key, cipher => 'Blowfish' });
	confess "No cipher!" unless $c;
	$self->{_cipher} = $c;
	return $self;
}

sub encrypt {
	my ($self, $data) = @_;
	confess "# No data to encrypt given!" unless defined($data);
	my $res = $Cache ? $Cache->{$data} : undef;
	return $res if defined($res);
	my $c = crc32($data);
	$res = $self->{_cipher}->encrypt_hex(pack("La*", $c, $data));
	$Cache->{$data} = $res if $Cache;
	return $res;
}

sub decrypt {
	my ($self, $data) = @_;
	my $d;
	eval { $d = $self->{_cipher}->decrypt_hex($data) };
	return undef unless defined($d);

	my ($c, $res) = unpack("La*", $d);
	return undef unless (defined($c) && defined($res));
	my $c1 = crc32($res);
	return $c1 == $c ? $res : undef;
}

1;
