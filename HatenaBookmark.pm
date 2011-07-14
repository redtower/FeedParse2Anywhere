package HatenaBookmark;

use strict;
use warnings;
use Moose;
use XML::Simple;
use LWP::Simple;

use Item;

sub parse($);
sub show_usage();

has id       => (is => 'rw', isa => 'Str');

sub getdata {
    my $self = shift;
    my $content = getxml($self->{'id'});
    if ($content) {
        return parse($content);
    } else {
        return '';
    }
}

sub parse($) {
    my ($content) = @_;
    my @results;

    my $tree = XMLin($content);
    for ( my $list = $tree->{'item'} ) {
      my @entries = @$list;
      for my $entry ( @entries ) {
        my $i = Item->new(
            id          => $entry->{'dc:date'},
            title       => $entry->{'title'},
            url         => $entry->{'link'},
            description => $entry->{'content:encoded'},
            date        => $entry->{'dc:date'},
            author      => $entry->{'creator'},
        );

        push(@results, $i);
      }
    }

    return \@results;
}

sub getxml($) {
    my ($id) = @_;
    my $url = 'http://b.hatena.ne.jp/' . $id . '/rss';
    my $dt = LWP::Simple::get($url);

    return $dt;
}
1;
