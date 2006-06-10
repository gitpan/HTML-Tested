use strict;
use warnings FATAL => 'all';

package HTML::Tested::Seal;
use base 'Class::Singleton';
use Crypt::CBC;
use Digest::CRC qw(crc32);

sub _new_instance {
	my ($class, $key) = @_;
	my $self = bless({}, $class);
	my $c = Crypt::CBC->new({ key => $key, cipher => 'Blowfish' });
	die "No cipher!" unless $c;
	$self->{_cipher} = $c;
	return $self;
}

sub encrypt {
	my ($self, $data) = @_;
	my $c = crc32($data);
	return $self->{_cipher}->encrypt_hex(pack("La*", $c, $data));
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
