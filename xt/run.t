use strict;
use warnings;
use Test::Builder;
use Test::More;
use BusyBird::Input::Feed::Run;
use FindBin;
use JSON qw(decode_json);
use Test::LWP::UserAgent;
use HTTP::Response;

if(!$ENV{BB_INPUT_FEED_NETWORK_TEST}) {
    plan('skip_all', "Set BB_INPUT_FEED_NETWORK_TEST environment to enable the test");
    exit;
}

sub check_output {
    my ($output_json) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $got = decode_json($output_json);
    is ref($got), "ARRAY", "got ARRAY-ref";
    my $num = scalar(@$got);
    cmp_ok $num, '>', 0, "got more than one (actually $num) statuses";
    foreach my $i (0 .. $#$got) {
        my $s = $got->[$i];
        ok defined($s->{id}), "status $i: id is defined";
        ok defined($s->{text}), "status $i: text is defined";
        ok defined($s->{busybird}{status_permalink}), "status $i: busybird.status_permalink is defined";
    }
}

my $run_cmd = "perl -Ilib $FindBin::RealBin/../bin/busybird_input_feed";

{
    note("--- STDIN -> STDOUT");
    my $output = `$run_cmd < '$FindBin::RealBin/../t/samples/stackoverflow.atom'`;
    check_output $output;
}

{
    note("--- URL -> STDOUT");
    my $output = `$run_cmd 'http://rss.slashdot.org/Slashdot/slashdot'`;
    check_output $output;
}

{
    note("--- URL -> URL");
    my $ua = Test::LWP::UserAgent->new(network_fallback => 1);
    my $output;
    $ua->env_proxy;
    $ua->map_response(qr{/timelines/home/statuses\.json}, sub {
        my ($request) = @_;
        $output = $request->decoded_content;
        my $mocked_res = HTTP::Response->new(200);
        $mocked_res->header('Content-Type' => 'application/json; charset=utf-8');
        $mocked_res->content(q{{"error":null,"count":10}});  ## count may be wrong...
        return $mocked_res;
    });
    BusyBird::Input::Feed::Run->run(
        download_url => 'http://rss.slashdot.org/Slashdot/slashdot',
        post_url => 'http://hogehoge.com/timelines/home/statuses.json',
        user_agent => $ua
    );
    ok defined($output), "output is captured";
    check_output $output;
}


## 
## 
## sub run_child {
##     my ($input_pipe, $output_pipe) = @_;
##     $input_pipe->reader;
##     $ouptut_pipe->writer;
##     close STDIN;
##     close STDOUT;
##     open STDIN, '<&=', $input_pipe->fileno or die "Cannot re-open STDIN";
##     open STDOUT, '>&=', $output_pipe->fileno or die "Cannot re-open STDOUT";
##     BusyBird::Input::Feed::Run->run();
## }
## 
## sub fork_child {
##     my $input_to_child = IO::Pipe->new;
##     my $output_from_child = IO::Pipe->new;
## 
##     my $child_pid = fork();
##     if(!defined($child_pid)) {
##         die "fork() failed. Abort.";
##     }elsif(!$child_pid) {
##         ## child
##         run_child($input_to_child, $output_from_child);
##         exit;
##     }
##     ## parent
##     $input_to_child->writer;
##     $output_from_child->reader;
##     return ($child_pid, $input_to_child, $output_from_child);
## }
## 
## my $input_feed = do {
##     my $filename = "t/samples/stackoverflow.atom";
##     open my $file, "<", $filename or die "Cannot open $filename: $!";
##     local $/;
##     <$file>;
## };
## 
## my ($child_pid, $writer, $reader) = fork_child;
## $writer->print($input_feed);
## $writer->close;
## my $got_statuses_json = <$reader>;
## waitpid $child_pid, 0;
## my $got_statuses = JSON->new->utf8->decode($got_statuses_json);
## 
## is scalar(@$got_statuses), 30, "30 statuses OK";
## is $got_statuses->[0]{id}, '1404624785|http://stackoverflow.com/q/24593005', "[0]{id} OK";


done_testing;

