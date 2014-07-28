use strict;
use warnings;
use Test::More;
use utf8;
use BusyBird::Input::Feed;
use Test::Deep 0.084 qw(cmp_deeply superhashof);
use File::Spec;

sub sh { superhashof({ @_ }) }

sub check_case {
    my ($label, $got_statuses, $case) = @_;
    is scalar(@$got_statuses), $case->{exp_num}, "$label: num of statuses OK";
    foreach my $i (0 .. $#{$case->{exp_partial}}) {
        my $got = $got_statuses->[$i];
        my $exp = $case->{exp_partial}[$i];
        cmp_deeply $got, $exp, "$label: status $i OK";
        is $got->{user}{profile_image_url}, undef, "$label: status $i: user.profile_image_url is not set";
    }
}

my $input = BusyBird::Input::Feed->new(use_favicon => 0);

## Only the statuses at the head are checked. Only status fields
## present in the expected statuses are checked.

my @testcases = (
    { filename => 'rtcpan.rdf',
      exp_num => 15,
      exp_partial => [
          ## If <guid> is not present, use <link> for item_id.
          ## "id" field is (timestamp | item_id)
          sh(id => '1363869367|https://rt.cpan.org/Ticket/Display.html?id=84118',
             text => 'I really beg you to take back the exception catching feature in Future 0.11',
             busybird => sh( status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84118' ),
             created_at => 'Thu Mar 21 12:36:07 +0000 2013',
             user => sh( screen_name => q{rt.cpan.org: Search Queue = 'future'} )),
          sh( id => '1364188145|https://rt.cpan.org/Ticket/Display.html?id=84187',
              text => 'needs_all() throws an exception when immediate failed subfutures are given',
              busybird => sh( status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84187' ),
              created_at => 'Mon Mar 25 05:09:05 +0000 2013',
              user => sh( screen_name => q{rt.cpan.org: Search Queue = 'future'} )),
          sh( id => '1364188230|https://rt.cpan.org/Ticket/Display.html?id=84188',
              text => 'Error message is not user-friendly for followed_by(), and_then(), or_else() and repeat()',
              busybird => sh( status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84188' ),
              created_at => 'Mon Mar 25 05:10:30 +0000 2013',
              user => sh( screen_name => q{rt.cpan.org: Search Queue = 'future'} )),
          sh( id => '1364188340|https://rt.cpan.org/Ticket/Display.html?id=84189',
              text => 'Behavior of repeat {...} foreach => [] may be counter-intuitive',
              busybird => sh( status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84189' ),
              created_at => 'Mon Mar 25 05:12:20 +0000 2013',
              user => sh( screen_name => q{rt.cpan.org: Search Queue = 'future'}))
      ]},
    { filename => 'slashdot.rss',
      exp_num => 25,
      exp_partial => [
          ## use <guid> for item_id. In this case, busybird.original.id should maintain the <guid>
          sh( id => '1404616500|http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35f940/sc/38/l/0Lhardware0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A392340Cby0E20A450Ethe0Etop0Especies0Ewill0Eno0Elonger0Ebe0Ehumans0Eand0Ethat0Ecould0Ebe0Ea0Eproblem0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm',
              text => q{By 2045 'The Top Species Will No Longer Be Humans,' and That Could Be a Problem},
              busybird => sh( status_permalink => 'http://rss.slashdot.org/~r/Slashdot/slashdot/~3/HdnfMBYoOr4/story01.htm',
                              original => sh( id => 'http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35f940/sc/38/l/0Lhardware0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A392340Cby0E20A450Ethe0Etop0Especies0Ewill0Eno0Elonger0Ebe0Ehumans0Eand0Ethat0Ecould0Ebe0Ea0Eproblem0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm' ) ),
              created_at => 'Sun Jul 06 03:15:00 +0000 2014',
              user => sh( screen_name => 'Slashdot' )),
          sh( id => '1404606780|http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35c953/sc/32/l/0Lscience0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A42540Ctwo0Eearth0Elike0Eexoplanets0Edont0Eactually0Eexist0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm',
              text => q{Two Earth-Like Exoplanets Don't Actually Exist},
              busybird => sh( status_permalink => 'http://rss.slashdot.org/~r/Slashdot/slashdot/~3/NcsdVQtQOQQ/story01.htm',
                              original => sh( id => 'http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35c953/sc/32/l/0Lscience0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A42540Ctwo0Eearth0Elike0Eexoplanets0Edont0Eactually0Eexist0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm' ) ),
              created_at => 'Sun Jul 06 00:33:00 +0000 2014',
              user => sh( screen_name => 'Slashdot' )),
      ]},
    { filename => 'stackoverflow.atom',
      exp_num => 30,
      exp_partial => [
          sh( id => '1404624785|http://stackoverflow.com/q/24593005',
              text => 'How to write Unit Test for IValidatableObject Model',
              busybird => sh( status_permalink => 'http://stackoverflow.com/questions/24593005/how-to-write-unit-test-for-ivalidatableobject-model',
                              original => sh( id => 'http://stackoverflow.com/q/24593005' )),
            
              ## use <updated> date
              created_at => 'Sun Jul 06 05:33:05 +0000 2014',
              user => sh( screen_name => 'Recent Questions - Stack Overflow' )),
          sh( id => '1404624716|http://stackoverflow.com/q/24593002',
              text => 'hide softkeyboard when it is called from menuitem',
              busybird => sh( status_permalink => 'http://stackoverflow.com/questions/24593002/hide-softkeyboard-when-it-is-called-from-menuitem',
                              original => sh( id => 'http://stackoverflow.com/q/24593002' )),
              created_at => 'Sun Jul 06 05:31:56 +0000 2014',
              user => sh( screen_name => 'Recent Questions - Stack Overflow' )),
      ]},
    { filename => 'googlejp.atom',
      exp_num => 25,
      exp_partial => [
          sh( id => '1404701402|tag:blogger.com,1999:blog-20042392.post-2515664455683743324',

              ## status text should be decoded.
              text => 'あたらしい「ごちそうフォト」で、あなたがどんな食通かチェックしましょう。',
              
              ## if there are multiple <link>s, use rel="alternate".
              busybird => sh( status_permalink => 'http://feedproxy.google.com/~r/GoogleJapanBlog/~3/RP_M-WXr_6I/blog-post.html',
                              original => sh( id => 'tag:blogger.com,1999:blog-20042392.post-2515664455683743324' )),

              ## <updated> is used instead of <published>
              created_at => 'Mon Jul 07 11:50:02 +0900 2014',
              user => sh( screen_name => 'Google Japan Blog' )),
          
          sh( id => '1403245680|tag:blogger.com,1999:blog-20042392.post-4467811587369881889',
              text => '最新の Chrome Experiment でキック、ドリブル、シュートを楽しもう!',
              busybird => sh( status_permalink => 'http://feedproxy.google.com/~r/GoogleJapanBlog/~3/qztQgCPoisw/chrome-experiment.html',
                              original => sh( id => 'tag:blogger.com,1999:blog-20042392.post-4467811587369881889' )),

              ## <published> is used when <updated> is missing
              created_at => 'Fri Jun 20 15:28:00 +0900 2014',
              user => sh( screen_name => 'Google Japan Blog' )),
      ]},
    { filename => 'slashdotjp.rdf',
      exp_num => 13,
      exp_partial => [
          sh( id => '1404899040|http://linux.slashdot.jp/story/14/07/09/097242/',
              text => 'ミラクル・リナックス、ソフトバンク・テクノロジーに買収される',
              busybird => sh( status_permalink => 'http://linux.slashdot.jp/story/14/07/09/097242/' ),
              created_at => 'Wed Jul 09 09:44:00 +0000 2014',
              user => sh( screen_name => 'スラッシュドット・ジャパン' )),
          sh( id => '1404896100|http://yro.slashdot.jp/story/14/07/09/0533213/',
              text => 'バイオハザードを手がけた三上真司氏の新作ホラーゲームはDLCでCERO Z相当になる',
              busybird => sh( status_permalink => 'http://yro.slashdot.jp/story/14/07/09/0533213/' ),
              created_at => 'Wed Jul 09 08:55:00 +0000 2014',
              user => sh( screen_name => 'スラッシュドット・ジャパン' )),
      ]},
    { filename => 'pukiwiki_rss09.rss',
      exp_num => 15,
      exp_partial => [
          ## both ID and timestamp are missing. item_id is <link>. timestamp is just missing.
          sh( id => 'http://debugitos.main.jp/index.php?Ubuntu%2FTrusty%A5%A4%A5%F3%A5%B9%A5%C8%A1%BC%A5%EB%A5%E1%A5%E2',
              text => 'Ubuntu/Trustyインストールメモ',
              busybird => sh( status_permalink => 'http://debugitos.main.jp/index.php?Ubuntu%2FTrusty%A5%A4%A5%F3%A5%B9%A5%C8%A1%BC%A5%EB%A5%E1%A5%E2' ),
              created_at => undef,
              user => sh( screen_name => q{DebugIto's} )),
      ]},
    { filename => 'nick.rss',
      exp_num => 20,
      exp_partial => [
          sh( id => '1405617373|http://www.nickandmore.com/?p=24392',

              ## decode XML Entities (like &#8217;)
              text => q{Disney XD’s “The 7D” Launches With Solid Ratings, App Hits 1.3M+ Downloads},
              busybird => sh( status_permalink => 'http://www.nickandmore.com/2014/07/17/disney-xds-the-7d-launches-with-solid-ratings-app-hits-1-3m-downloads/',
                              original => sh( id => 'http://www.nickandmore.com/?p=24392' )),
              created_at => 'Thu Jul 17 17:16:13 +0000 2014',
              user => sh( screen_name => 'NICKandMORE' )),
          sh( id => '1405613508|http://www.nickandmore.com/?p=24371',

              ## XML Entities with &amp;
              text => q{Disney Television Animation Announces “Haunted Mansion” Special, Three Pilots & Short-Form Series},
              busybird => sh( status_permalink => 'http://www.nickandmore.com/2014/07/17/disney-television-animation-announces-haunted-mansion-special-three-pilots-short-form-series/',
                              original => sh( id => 'http://www.nickandmore.com/?p=24371' )),
              created_at => 'Thu Jul 17 16:11:48 +0000 2014',
              user => sh( screen_name => 'NICKandMORE' ))
      ]}
);

foreach my $case (@testcases) {
    my $filepath = File::Spec->catfile(".", "t", "samples", $case->{filename});
    check_case "$case->{filename} parse_file()", $input->parse_file($filepath), $case;
    open my $file, "<", $filepath or die "Cannot open $filepath: $!";
    my $data = do { local $/; <$file> };
    check_case "$case->{filename} parse()", $input->parse($data), $case;
    check_case "$case->{filename} parse_string()", $input->parse_string($data), $case;
    close $file;
}

done_testing;

