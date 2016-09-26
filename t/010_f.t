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
my $FILE = 't/010_f.t';

my $log = Log::Minimal.new(:timezone(0));

subtest {
    {
        use Grammar::Tracer;
        my $out = capture_stderr {
            $log.critf('critical');
        };
        like $out, rx{^<$DATETIME>" [CRITICAL] critical at $FILE line "<{$?LINE - 2}>\n$};
    }

    {
        my $out = capture_stderr {
            $log.critf('critical:%s', 'foo');
        };
        like $out, rx{^<$DATETIME>" [CRITICAL] critical:foo at $FILE line "<{$?LINE - 2}>\n$};
    }
}, 'test for critf';

subtest {
    {
        my $out = capture_stderr {
            $log.warnf('warn');
        };
        like $out, rx{^<$DATETIME>" [WARN] warn at $FILE line "<{$?LINE - 2}>\n$};
    }

    {
        my $out = capture_stderr {
            $log.warnf('warn:%s', 'foo');
        };
        like $out, rx{^<$DATETIME>" [WARN] warn:foo at $FILE line "<{$?LINE - 2}>\n$};
    }
}, 'test for warnf';

subtest {
    {
        my $out = capture_stderr {
            $log.infof('info');
        };
        like $out, rx{^<$DATETIME>" [INFO] info at $FILE line "<{$?LINE - 2}>\n$};
    }

    {
        my $out = capture_stderr {
            $log.infof('info:%s', 'foo');
        };
        like $out, rx{^<$DATETIME>" [INFO] info:foo at $FILE line "<{$?LINE - 2}>\n$};
    }
}, 'test for infof';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    {
        my $out = capture_stderr {
            $log.debugf('debug');
        };
        like $out, rx{^<$DATETIME>" [DEBUG] debug at $FILE line "<{$?LINE - 2}>\n$};
    }

    {
        my $out = capture_stderr {
            $log.debugf('debug:%s', 'foo');
        };
        like $out, rx{^<$DATETIME>" [DEBUG] debug:foo at $FILE line "<{$?LINE - 2}>\n$};
    }
}, 'test for debugf';

subtest {
    dies-ok {
        $log.errorf('error');
    }; # XXX

    dies-ok {
        $log.errorf('error: %s', 'foo');
    }; # XXX
}, 'test for errorf';

done-testing;
