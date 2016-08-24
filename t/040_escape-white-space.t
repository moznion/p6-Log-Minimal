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
my $FILE = 't/040_escape-white-space.t';

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^<$DATETIME>" [CRITICAL] s\r\n\\te at $FILE line "<{$?LINE - 2}>\n$};
}, 'default, escape white space';

subtest {
    my $log = Log::Minimal.new(:escape-whitespace(False), :timezone(0));
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^<$DATETIME>" [CRITICAL] s\r\n\te at $FILE line "<{$?LINE - 2}>\n$};
    # like $out, rx{^<$DATETIME>' '\[CRITICAL\]' 's\r\n\te' 'at' 't'/'040_escape'-'white'-'space'.'t' 'line' '17\n$};
}, 'do not escape white space';

done-testing;
