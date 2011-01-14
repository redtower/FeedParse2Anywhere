package SMail;

use strict;
use warnings;
use base qw(Class::Accessor);
use Mail::Sendmail;
use MIME::Lite;
use Encode;
use utf8;

__PACKAGE__->mk_accessors( qw(from to subject message type) );

sub new {
    my $class = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};

    my $o = $class->SUPER::new({
        from => '',
        to => '',
        subject => '',
        message => '',
        type => 'text/plain; charset="iso-2022-jp"',
        %$args
    });

    return $o;
}

sub type {
    my ($self, $type) = @_;
    my $stype = $self->{type};
    if ($type =~ /^html$/) {
        $stype =~ s/plain/html/;
    } elsif ($type =~ /^plain$/) {
        $stype =~ s/html/plain/;
    } else {
        $stype = $type;
    }
    return $self->_type_accessor($stype);
}

sub send {
    my $self = shift;
    my $s;
    my $m;
    if ($self->{subject}) {
        $s = encode("MIME-Header-ISO_2022_JP", $self->{subject});
    }
    if ($self->{message}) {
        $m = encode("iso-2022-jp", $self->{message});
    }

    my %mail = (
        "Content-Type" => $self->{type},
        To             => $self->{to},
        From           => $self->{from},
        Subject        => $s,
        Message        => $m,
    );

    sendmail(%mail);
}
1;
