use v6;
use Terminal::ANSIColor;

unit class Log::Minimal;

our enum LogLevel <MUTE DEBUG INFO WARN CRITICAL ERROR>;

our $colors = {
    INFO     => 'green',
    DEBUG    => 'red on_white',
    WARN     => 'black on_yellow',
    CRITICAL => 'black on_red',
    ERROR    => 'red on_black',
};

has LogLevel $.default_log_level is rw = DEBUG;
has Bool $.escape_whitespace = True;
has Bool $.color = %*ENV<LM_COLOR> ?? True !! False;
has Str $.env_debug = "LM_DEBUG";
has Int $.default_trace_level = 0;
has Sub $.print is rw; # (DateTime :$time, Str :$messages, Str :$trace); <== not yet implemented...
has Sub $.die is rw; # (DateTime :$time, Str :$messages, Str :$trace); <== not yet implemented...

method critf(*@text) {
    self!log(CRITICAL, False, False, @text);
}

method warnf(*@text) {
    self!log(WARN, False, False, @text);
}

method infof(*@text) {
    self!log(INFO, False, False, @text);
}

method debugf(*@text) {
    my Bool $env_debug = %*ENV{$.env_debug} ?? True !! False;
    if $env_debug && DEBUG.value >= $.default_log_level.value {
        self!log(DEBUG, False, False, @text);
    }
}

method errorf(*@text) {
    temp $.default_log_level = DEBUG;
    self!log(ERROR, False, True, @text);
}

method critff(*@text) {
    self!log(CRITICAL, True, False, @text);
}

method warnff(*@text) {
    self!log(WARN, True, False, @text);
}

method infoff(*@text) {
    self!log(INFO, True, False, @text);
}

method debugff(*@text) {
    my Bool $env_debug = %*ENV{$.env_debug} ?? True !! False;
    if $env_debug && DEBUG.value >= $.default_log_level.value {
        self!log(DEBUG, True, False, @text);
    }
}

method errorff(*@text) {
    temp $.default_log_level = DEBUG;
    self!log(ERROR, True, True, @text);
}

method !log(LogLevel $log_level, Bool $full_trace, Bool $die, *@text) {
    if $.default_log_level.value == 0 || $log_level.value < $.default_log_level.value {
        # NOP: disabled by log level
        return;
    }

    my $time = DateTime.new(now);

    my $trace = '';
    if $full_trace {
        my @bts = ();
        my $i = $.default_trace_level + 4;
        loop {
            my $bt = callframe($i++);
            @bts.push($bt);
        }
        CATCH {
            when 'ctxcaller needs an MVMContext' {
                $trace = 'at ' ~ @bts[0..*-2].map(-> $bt {sprintf('%s line %s', $bt.file, $bt.line)}).join(', ');
            }
        }
    } else {
        my $bt = callframe($.default_trace_level + 3);
        $trace = sprintf('at %s line %s', $bt.file, $bt.line);
    }

    my $messages = '';
    if (@text == 1 && defined @text[0]) {
        $messages ~= @text[0];
    } elsif (@text >= 2)  {
        $messages = sprintf(@text.shift, @text);
    }

    if ($.escape_whitespace) {
        $messages = $messages.subst(/\x0d/, '\r', :g);
        $messages = $messages.subst(/\x0a/, '\n', :g);
        $messages = $messages.subst(/\x09/, '\t', :g);
    }

    if ($.color) {
        $messages = colored($messages, $colors{$log_level.key});
    }

    if ($die) {
        self!die(:$time, :$log_level, :$messages, :$trace);
    } else {
        self!print(:$time, :$log_level, :$messages, :$trace);
    }
}

my class Log::Minimal::Error is Exception {
    has Str $.message;

    method message(Exception:D:) returns Str:D {
        return $!message;
    }
    method backtrace(Exception:D:) returns Backtrace:D {
        return Backtrace.new();
    }
}

method !print(DateTime :$time, LogLevel :$log_level, Str :$messages, Str :$trace) {
    my $format = "$time [$log_level] $messages $trace";
    if $.print {
        $format = $.print.(:$time, :$log_level, :$messages, :$trace);
    }

    note $format;
}

method !die(DateTime :$time, LogLevel :$log_level, Str :$messages, Str :$trace) {
    my $format = "$time [$log_level] $messages $trace";
    if $.die {
        $format = $.die.(:$time, :$log_level, :$messages, :$trace)
    }

    Log::Minimal::Error.new(message => $format).die;
}

=begin pod

=head1 NAME

Log::Minimal - Minimal logger for perl6

=head1 SYNOPSIS

  use Log::Minimal;
  my $l = Log::Minimal.new;
  $l.critf('critical');

=head1 DESCRIPTION

Log::Minimal is a minimal and customizable logger for perl6.
This logger provides logging functions  according to logging level with line (or stack) trace.

This package is perl6 port of Log::Minimal of perl5.

=head1 METHODS

=head1 CONFIGURATIONS

=head1 COPYRIGHT AND LICENSE

Copyright 2015 moznion <moznion@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

