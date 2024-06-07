unit module Checkwriter::Handlers;

#=== exported subs ===
# Receives a path to the user's register.json file
# along with data for the desired actions:
# 
# c - make a copy of the register
# d - deposit
# p - pay-to, write a check
# w - withdraw without a check (debit)
# z - null (zero) a check amount along with optional added memo
subset Transact of Str is export where * ~~ /^ :i [c|d|p|w|z]/;
sub handle-register(Transact $action, :$path!, :$debug) is export {
    with $action {
        when /c/ { 
        }
        when /d/ { 
        }
        when /p/ { 
        }
        when /w/ { 
        }
        when /z/ { 
        }
        default {
            die qq:to/HERE/;
            HERE
        }
    }
}

#=== non-exported subs ===
