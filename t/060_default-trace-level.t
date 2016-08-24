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
    (<[Zz]> || (<[\-\+]>) (\d\d) (':'? (\d\d))? )? # timezone
/;
my $FILE = 't/060_default-trace-level.t';

subtest {
    my $log = Log::Minimal.new(:default-trace-level(2), :timezone(0));
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^<$DATETIME>" [CRITICAL] critical at $FILE line "<{$?LINE - 3}>\n$};
}, 'test for default-trace-level';

done-testing;
