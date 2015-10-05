use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new;

    subtest {
        my $out = capture_stderr {
            $log.critf('critical');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical' 'at' 't\/01\-basic\.t' 'line' '11\n$}
    }, 'test for critf';

    subtest {
        my $out = capture_stderr {
            $log.warnf('warn');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[WARN\]' 'warn' 'at' 't\/01\-basic\.t' 'line' '18\n$}
    }, 'test for warnf';

    subtest {
        my $out = capture_stderr {
            $log.infof('info');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[INFO\]' 'info' 'at' 't\/01\-basic\.t' 'line' '25\n$}
    }, 'test for infof';

    subtest {
        my $out = capture_stderr {
            $log.debugf('debug');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[DEBUG\]' 'debug' 'at' 't\/01\-basic\.t' 'line' '32\n$}
    }, 'test for debugf';

    subtest {
        dies-ok {
            $log.errorf('error');
        }; # XXX
    }, 'test for errorf';
}, 'test for XXXf';

done-testing;
