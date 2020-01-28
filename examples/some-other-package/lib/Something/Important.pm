package Something::Important;
use strict;
use warnings;
use File::Basename qw(dirname);
use feature 'say';

sub assert_stuff {
    open my $fh, '<', dirname(__FILE__) . '/../../important-data.txt'
        or die $!;
    chomp(my $content = <$fh>);
    $content eq 'real stuff here' or die "oh noes! content is '$content'";
    close $fh;
}

1;
