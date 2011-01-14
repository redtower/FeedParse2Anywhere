package GoogleReader;

use strict;
use warnings;
use Moose;
use WWW::Mechanize;
use XML::FeedPP;

use Item;

sub parse($);
sub getxml($$);
sub google_login($$);
sub input_password();

has id       => (is => 'rw', isa => 'Str');
has password => (is => 'rw', isa => 'Str');

sub getdata {
    my ($self) = @_;
    $self->{'password'} = input_password() if !$self->{'password'};

    my $content;
    while(!$content) {
        my $st;
        $content = getxml($self->{'id'}, $self->{'password'}) or $st++;
        if ($st) {
            print "Login Error. Please Try Again.\n";
            $self->{'password'} = input_password();
        }
    }

    return parse($content);
}

sub parse($) {
    my ($content) = @_;
    my @results;

    my $feed = XML::FeedPP->new( $content );
    foreach my $n ( $feed->get_item() ) {
        my $i = Item->new(
            id          => $n->guid(),
            title       => $n->title(),
            url         => $n->link(),
            description => $n->description() || '',
            date        => $n->pubDate(),
            author      => $n->author(),
        );

        push(@results, $i);
    }

    return \@results;
}

sub getxml($$) {
    my ($email, $pass) = @_;

    my $mech = google_login($email, $pass) or return;
    $mech->get('http://www.google.com/reader/atom/user/-/state/com.google/starred');

    return $mech->content;
}

sub google_login($$) {
    my ($email, $pass) = @_;
    my $mech = WWW::Mechanize->new;

    $mech->get('http://www.google.com/reader') || die $!;
    $mech->submit_form(
        form_number => 1,
        fields => {
            Email  => $email,
            Passwd => $pass
        }
    );

    $mech->get($mech->res->request->uri);
    my $refresh = $mech->res->headers->header('Refresh') or return;
    $refresh =~ /url='(.*)'/;
    $mech->get($1);
    $mech->get($mech->res->request->uri);

    return $mech;
}

sub input_password() {
    my $pass;

    while (!$pass) {
        print "Password --> ";
        system "stty -echo";
        chomp($pass = <STDIN>);
        print "\n";
        system "stty echo";
    }

    return $pass;
}
1;
