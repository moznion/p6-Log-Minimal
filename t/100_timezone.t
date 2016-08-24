use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my $DATETIME = rx/
    (<[+-]>? \d**4 \d*)                            # year
    '-'
    (\d\d)                                         # month
    '-'
    (\d\d)                                         # day
    <[Tt]>                                         # time separator
    (\d\d)                                         # hour
    ':'
    (\d\d)                                         # minute
    ':'
    (\d\d[<[\.,]>\d ** 1..6]?)                     # second
    (<[\-\+]>) (\d\d) (':'? (\d\d))?     # MANDATORY non-UTC timezone
/;
my $FILE = 't/100_timezone.t';

my $timezone = DateTime.new('2015-12-24T12:23:00+0900').timezone;
my $log = Log::Minimal.new(:$timezone);

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^<$DATETIME>" [CRITICAL] critical at $FILE line "<{$?LINE - 2}>\n$};
        #like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2\+09\:00' '\[CRITICAL\]' 'critical' 'at' 't\/100_timezone\.t' 'line' '11\n$};
}, 'test for critf';

done-testing;
