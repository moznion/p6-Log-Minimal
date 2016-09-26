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
my $FILE = 't/080_custom-format.t';

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
        note "$trace $messages [$log-level] $time";
    }

    my $out = capture_stderr {
        $log.warnf('msg');
    }
    like $out, rx{"at $FILE line "<{$?LINE - 2}>' msg [WARN] '<$DATETIME>\n};
}, 'custom print';

done-testing;
