use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new(:default_trace_level(2));
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical' 'at' 't\/060_default\-trace\-level\.t' 'line' '8\n$}
}, 'test for default_trace_level';

done-testing;
