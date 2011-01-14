package Item;
use Moose;
use Encode qw ( encode );

has id          => (is => 'rw', isa => 'Any');
has url         => (is => 'rw', isa => 'Any');
has title       => (is => 'rw', isa => 'Any');
has description => (is => 'rw', isa => 'Any');
has date        => (is => 'rw', isa => 'Any');
has author      => (is => 'rw', isa => 'Any');

sub toString {
    my $self = shift;
    my $str;

    $str .= $self->id() if $self->id();
    $str .= ',';
    $str .= $self->title() if $self->title();
    $str .= ',';
    $str .= $self->url() if $self->url();
    $str .= ',';
    $str .= $self->description() if $self->description();
    $str .= ',';
    $str .= $self->date() if $self->date();
    $str .= ',';
    $str .= $self->author() if $self->author();

    return $str;
}

1;
