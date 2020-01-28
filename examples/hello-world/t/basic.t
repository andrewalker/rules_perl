use strict;
use warnings;
use Test::More;
use Test::Output;
use_ok('Hello');
use FindBin '$Bin';

ok(my $h = Hello->new({ file => "$Bin/foo.txt" }), 'can instantiate Hello');
isa_ok($h, "Hello");
ok($h->can('say_hello'), 'Hello can say_hello');
ok( -f $h->file, "File exists: " . $h->file);
stdout_is(
    sub {
        $h->say_hello();
    },
    "Hello Foo\n", "say hello says hello to Foo"
);

done_testing;
