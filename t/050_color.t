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
my $FILE = 't/050_color.t';

%*ENV<LM_COLOR> = True;
my $log = Log::Minimal.new(:timezone(0));

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };

    if $out ~~ m{^<$DATETIME>" [CRITICAL] "(.+)" at $FILE line "<{$?LINE - 3}>\n$} {
        is $0, "\x[1b][30;41mcritical\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    };
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnf('warn');
    };

    if $out ~~ m{^<$DATETIME>" [WARN] "(.+)" at $FILE line "<{$?LINE - 3}>\n$} {
        is $0, "\x[1b][30;43mwarn\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for warnf';

subtest {
    my $out = capture_stderr {
        $log.infof('info');
    };

    if $out ~~ m{^<$DATETIME>" [INFO] "(.+)" at $FILE line "<{$?LINE - 3}>\n$} {
        is $0, "\x[1b][32minfo\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for infof';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    my $out = capture_stderr {
        $log.debugf('debug');
    };

    if $out ~~ m{^<$DATETIME>" [DEBUG] "(.+)" at $FILE line "<{$?LINE - 3}>\n$} {
        is $0, "\x[1b][31;47mdebug\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for debugf';

done-testing;
