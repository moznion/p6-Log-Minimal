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
my $FILE = 't/020_ff.t';

my $log = Log::Minimal.new(:timezone(0));

subtest {
    my $out = capture_stderr {
        $log.critff('critical');
    };
    like $out, rx{^<$DATETIME>" [CRITICAL] critical at $FILE line "<{$?LINE - 2}> \, .+$};
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnff('warn');
    };
    like $out, rx{^<$DATETIME>" [WARN] warn at $FILE line "<{$?LINE - 2}> \, .+$};
}, 'test for warnff';

subtest {
    my $out = capture_stderr {
        $log.infoff('info');
    };
    like $out, rx{^<$DATETIME>" [INFO] info at $FILE line "<{$?LINE - 2}> \, .+$};
}, 'test for infoff';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    my $out = capture_stderr {
        $log.debugff('debug');
    };
    like $out, rx{^<$DATETIME>" [DEBUG] debug at $FILE line "<{$?LINE - 2}> \, .+$};
}, 'test for debugff';

subtest {
    dies-ok {
        $log.errorff('error');
    }; # XXX
}, 'test for errorff';

done-testing;
