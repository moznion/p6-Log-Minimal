use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new;
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 's\\r\\n\\te' 'at' 't'/'04'-'escape'-'white'-'space'.'t' 'line' '9\n$};
}, 'default, escape white space';

subtest {
    my $log = Log::Minimal.new(:escape_whitespace(False));
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 's\r\n\te' 'at' 't'/'04'-'escape'-'white'-'space'.'t' 'line' '17\n$};
}, 'do not escape white space';

done-testing;