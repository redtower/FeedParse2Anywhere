package Instapaper;

use strict;
use warnings;
use LWP::Simple;

sub new {
    my $class = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};
    my $self = {
        url => '',
        header => '',
        body => '',
        %$args
    };

    if ($self->{url}) {
        my $r = getdata($self) || return;
        $self->{header} = $r->{header};
        $self->{body} = $r->{body};
    }

    return bless $self, $class;
}

sub url {
    my $self = shift;
    my $url = shift;

    if ($url) {
        $self->{url} = $url;
        $self->{header} = '';
        $self->{body}   = '';
        my $r = getdata($self) || return;
        $self->{header} = $r->{header};
        $self->{body}   = $r->{body};
    }

    return $self->{url};
}

sub header {
    my $self = shift;
    return $self->{header};
}

sub body {
    my $self = shift;
    my $r = undef;
    foreach (@{$self->{body}}) {
        $r .= $_;
    }
    return $r;
}

sub getdata {
    my $self = shift;
    my $html = undef;
    my $cnt = 0;
    do {
        sleep 10 if $cnt;
        $cnt++;
        #print "GET:[$cnt] " . mkurl($self->{url}) . "\n";
        $html = get(mkurl($self->{url}));
    } while (!$html && $cnt < 5);
    #print "OK :[$cnt] " . mkurl($self->{url}) . "\n" if $html;

    return parse($html);
}

sub parse {
    my $html = shift or return;

    if ($html =~ /this page is not available in Instapaper/) {
        return;
    } else {

        my $subj  = undef;
        my @lines = ();
        for ( split /\n/, $html ) {
            if ( /<title>/../<\/title>/ ) {
                # get <title> text
                $subj .= $_;
            }
            if ( /<a.+?href=\"([^\"]+)\"/ ) {
                # decode URL
                tr/+/ /;
                s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;
            }
            push(@lines, $_,"\n");
        }

        return {'header'=>$subj, 'body'=>\@lines};
    }
}

sub mkurl {
    my $url  = shift;

    $url =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $url =~ tr/ /+/;
    $url =  'http://www.instapaper.com/text?u=' . $url;

    return $url;
}
1;
