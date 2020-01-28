#!/usr/bin/env perl
use strict;
use warnings;
use Hello;
use FindBin '$Bin';

my $h = Hello->new({ file => "$Bin/name.txt" });
$h->say_hello();
