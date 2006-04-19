#!/usr/bin/perl -w
use strict;
use File::Basename qw(dirname);
use Template;
use Cwd qw(abs_path);

my $libdir;
BEGIN {
	$libdir = dirname($0) . "/../lib";
	unshift @INC,  $libdir;
};

package T;
use base 'HTML::Tested';
__PACKAGE__->make_tested_form('v', default_value => 'u', children => [
		a => 'edit_box', { default_value => 5
			, constraints => [ qw(/^\d+$/) ],
		}, b => 'edit_box', { constraints => [ qw(/^\d+$/) ], }
]);

package main;

my $object = T->new;
my $stash = {};
$object->ht_render($stash);

my $ap = abs_path($libdir);
my $t = Template->new;
my $input = <<ENDT;
<html>
<head>
<script language="javascript" src="file:///$ap/HTML/Tested/Value/form.js">
</script>
</head>
<body>
[% v %]
[% a %] <br />
[% b %] <br />
<input type="submit" />
</form>
</body>
</html>
ENDT
$t->process(\$input, $stash) or die $t->error();
