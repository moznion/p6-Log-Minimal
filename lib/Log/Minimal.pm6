use v6;
unit class Log::Minimal;

our enum LogLevel <MUTE DEBUG INFO WARN CRITICAL ERROR>;

has LogLevel $.default_log_level = DEBUG;
has Bool $.escape_whitespace = True;
has Bool $.color = %*ENV<LM_COLOR> ?? True !! False;
has Str $.env_debug = "LM_DEBUG";

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
    if $env_debug || DEBUG.value >= $.default_log_level.value {
        self!log(DEBUG, False, False, @text);
    }
}

method croakf(*@text) {
    # $.default_log_level = DEBUG; # TODO restore by defer
    self!log(ERROR, False, True, @text);
}

# TODO support trace
# method critff(*@text) {
#     _log( "CRITICAL", 1, @_ );
# }
#
# method warnff(*@text) {
#     _log( "WARN", 1, @_ );
# }
#
# method infoff(*@text) {
#     _log( "INFO", 1, @_ );
# }
#
# method debugff(*@text) {
#     return if !$ENV{$ENV_DEBUG} || $log_level_map{DEBUG} < $log_level_map{uc $LOG_LEVEL};
#     _log( "DEBUG", 1, @_ );
# }
#
# method croakff(*@text) {
#     local $PRINT = $DIE;
#     local $LOG_LEVEL = 'DEBUG';
#     _log( "ERROR", 1, @_ );
# }

method !log(LogLevel $log_level, Bool $full_trace, Bool $die = False, *@text) {
    if $.default_log_level.value == 0 || $log_level.value < $.default_log_level.value {
        # NOP: disabled by log level
        return;
    }

    my $time = DateTime.new(now);

    my $trace = '';
    if ($full_trace) {
        # my $i=$TRACE_LEVEL+1;
        # my @stack;
        # while ( my @caller = caller($i) ) {
        #     push @stack, "$caller[1] line $caller[2]";
        #     $i++;
        # }
        # $trace = join ", ", @stack
    } else {
        # my @caller = caller($TRACE_LEVEL+1);
        # $trace = "$caller[1] line $caller[2]";
    }

    my $messages = '';
    if (@text == 1 && defined @text[0]) {
        $messages = @text[0];
        # TODO support AUTODUMP
        # $messages = $AUTODUMP ? ''.Log::Minimal::Dumper->new($_[0]) : $_[0];
    }
    elsif (@text >= 2)  {
        $messages = sprintf(@text.shift, @text);
        # TODO support AUTODUMP
        # $messages = sprintf(shift, map { $AUTODUMP ? Log::Minimal::Dumper->new($_) : $_ } @_);
    }

    if ($.escape_whitespace) {
        $messages = $messages.subst(/\x0d/, '\r', :g);
        $messages = $messages.subst(/\x0a/, '\n', :g);
        $messages = $messages.subst(/\x09/, '\t', :g);
    }

    if ($.color) {
        # TODO
    }

    self!print(:$time, :$log_level, :$messages, :$trace, :$die);
}

method !print(DateTime :$time, LogLevel :$log_level, Str :$messages, Str :$trace, Bool :$die) {
    if ($die) {
        die "$time [$log_level] $messages";
    } else {
        $*ERR.print("$time [$log_level] $messages\n");
    }

    # TODO support trace
    # warn "$time [$log_level] $messages at $trace\n";
}

=begin pod

=head1 WIP

WIP WIP WIP

=head1 NAME

Log::Minimal - Minimal logger

=head1 SYNOPSIS

  use Log::Minimal;

=head1 DESCRIPTION

Log::Minimal is perl6 port of Log::Minimal of perl5.

=head1 COPYRIGHT AND LICENSE

Copyright 2015 moznion <moznion@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
