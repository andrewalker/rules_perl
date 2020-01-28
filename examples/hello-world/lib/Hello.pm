package Hello;
use strict;
use warnings;
use feature 'say';
use Something::Important;
Something::Important::assert_stuff();

sub new {
    my ( $class, $args ) = @_;
    return bless $args, $class;
}

sub file {
    my ($self, $file) = @_;
    $self->{file} = $file if $file;
    return $self->{file};
}

sub say_hello {
    open my $fh, '<', shift->file or die $!;
    my $name = <$fh>;
    chomp $name;


    say "Hello $name";
}

1;
