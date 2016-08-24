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
my $FILE = 't/090_autodump.t';

subtest {
    {
        my $log = Log::Minimal.new(:autodump(True), :timezone(0));
        my $out = capture_stderr {
            $log.critf({foo => 'bar'});
        };
        like $out, rx{^<$DATETIME>' [CRITICAL] :foo("bar")'" at $FILE line "<{$?LINE - 2}>\n$};
    }

    {
        my $log = Log::Minimal.new(:timezone(0));
        {
            temp $log.autodump = True;

            my $out = capture_stderr {
                $log.critf('%s', {foo => 'bar'});
            };
            like $out, rx{^<$DATETIME>' [CRITICAL] :foo("bar")'" at $FILE line "<{$?LINE - 2}>\n$};
        }
        is $log.autodump, False;
    }
}, 'test for critf';

done-testing;
