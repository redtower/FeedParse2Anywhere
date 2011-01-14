package Fp2aConfig;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = { @_ };
    $self->{'file'}  = 'fp2a.cfg'   if !$self->{'file'};
    $self->{'label'} = 'lastid-hb:' if !$self->{'label'};

    return bless $self, $class;
}

sub get_lastid {
    my $self = shift;
    my $lastid;

    if ( -e $self->{file} ) {
        open(LID, $self->{file});
        while (<LID>) {
            chomp;
            if (/^\#/) {
                # skip comment.
            } elsif (/^$/) {
                # skip blank line.
            } elsif (/^$self->{label}(.*)$/) {
                $lastid = $1;
            } else {
                # skip
            }
        }
        close(LID);
    }

    return $lastid;
}

sub put_lastid {
    my ($self, $id) = @_;

    my $cfg = $self->{'file'};
    my $tmp = $cfg . '.tmp';

    if ($id) {
        open(TMP, '>' . $tmp) or die 'Temporary file not open';

        if (open(LID, '<' . $cfg)) {
            my @buff = <LID>;
            close(LID);

            foreach my $l (@buff) {
                chomp($l);

                if ($l =~ /^$self->{'label'}(.*)$/) {
                    # skip
                } else {
                    print TMP $l . "\n";
                }
            }
        }

        print TMP $self->{'label'} . $id . "\n";
        close(TMP);

        unlink($cfg);
        rename($tmp, $cfg);
    }
}
1;
