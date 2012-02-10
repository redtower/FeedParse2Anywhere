#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Encode qw( encode );
use File::Basename qw( basename );

use GoogleReader;
use HatenaBookmark;
use SMail;
use Instapaper;
use Item;
use Fp2aConfig;

sub put_result($$$);
sub show_usage();
sub show_version();

my $VERSION = 0;

my %o =(
    'kind'=>'grs',
    'password'=>'',
    'file'=>'lastid.cfg',
    'to'=>[],
    'from'=>'foo@bar.co.jp',
);
GetOptions(\%o,
    'kind=s',
    'id=s',
    'password:s',
    'file=s',
    'label=s',
    'to=s{,}',
    'from=s',
    'tags=s',
    'help',
    'debug',
    'version',
) or $o{'help'}++;

show_version() if $o{'version'};
show_usage() if $o{'help'} || !$o{'id'};

my $obj;
my $label;

if ($o{'kind'} =~ /grs/) {
    $obj = GoogleReader->new(
        id => $o{'id'},
        password => $o{'password'},
        file => $o{'file'},
    ) or die "Instance Create Error";

    $o{'label'} = 'lastid-grs:'           if !$o{'label'};
    $o{'tags'}  = 'google_reader_starred' if !$o{'tags'};
} elsif($o{'kind'} =~ /hb/) {
    $obj = HatenaBookmark->new(
        id => $o{'id'},
        file => $o{'file'},
    ) or die "Instance Create Error";

    $o{'label'} = 'lastid-hb:'      if !$o{'label'};
    $o{'tags'}  = 'hatena_bookmark' if !$o{'tags'};
} else {
    die 'kind error. set grs or hb. GoogleReaderStarred(grs) or HatenaBookmark(hb)';
}
my $items = $obj->getdata();
if ($items) {
    put_result($o{'label'}, $items, $o{'from'});
}

sub put_result($$$) {
    my ($label, $items, $from) = @_;

    my $lid = Fp2aConfig->new(label => $label);
    my $pre_lastid = $lid->get_lastid();
    my $next_lastid;

    my $io = Instapaper->new();
    foreach my $n (@{$items}) {
        last if ($pre_lastid && $n->id() eq $pre_lastid);

        if (scalar(@{$o{'to'}})) {
            my $data = "<a href=\"" . $n->url() . "\">" . $n->title() . "</a>";
            if ($io->url($n->url())) {
                $data .= $io->body();
            } else {
                $data .= $n->description() if $n->description();
            }
            my $subj = $n->title() . '@' . $o{'tags'};
            my $m = SMail->new({from => $from, subject => $subj, message => $data});

            $m->type('html');

            foreach my $to (@{$o{'to'}}){
                $m->to($to);
                $m->send();
            }
        } else {
            print encode('utf-8', $n->toString()) . "\n";
        }

        $next_lastid = $n->{'id'} if ! $next_lastid;
    }

    $lid->put_lastid($next_lastid) if $next_lastid;
}

sub show_usage() {
    print <<"EOD";

Usage: perl $0 [Options]

 Options:
   --kind (grs|hb)      GoogleReaderStarred(grs) or HatenaBookmark(hb)
   --id userid          Google or Hatena User ID
   --password password  Google Password(only GoogleReaderStarred)
   --file filename      Last ID file
   --label label        Last ID's Label(ex. 'lastid-grs:' or 'lastid-hb')
   --to email-address   Destination Address(an specify multiple is ok)
   --from email-address Source Address
   --tags tag           Tag Name
   --help               Show this message.
   --debug              Debug mode
   --version            Show Version
EOD
    exit;
}

sub show_version() {
    print basename($0) . " Ver." . $VERSION . "\n";
    exit;
}
