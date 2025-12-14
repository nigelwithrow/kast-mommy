#!/usr/bin/env kast
use std.prelude.*;

let env_arg_or_default = (.arg :: string, .default :: string) -> string => (
    match std.sys.get_env arg with (
        | :Found s => s
        | :NotFound => default
    )
);

# Environment variables to configure kast-mommy
# SHELL_MOMMYS_LITTLE - what to call you~ (default: "girl")
# SHELL_MOMMYS_PRONOUNS - what pronouns mommy will use for themself~ (default: "her")
# SHELL_MOMMYS_ROLES - what role mommy will have~ (default "mommy")
# 
let DEF_WORDS_LITTLE = env_arg_or_default (.arg = "SHELL_MOMMYS_LITTLE", .default = "girl");
let DEF_WORDS_PRONOUNS = env_arg_or_default (.arg = "SHELL_MOMMYS_PRONOUNS", .default = "her");
let DEF_WORDS_ROLES = env_arg_or_default (.arg = "SHELL_MOMMYS_ROLES", .default = "mommy");
let DEF_ONLY_NEGATIVE = match std.sys.get_env "SHELL_MOMMYS_ONLY_NEGATIVE" with (
    | :Found _ => true
    | :NotFound => false
);
let POSITIVE_RESPONSES = std.sys.get_env "SHELL_MOMMYS_POSITIVE_RESPONSES";
let NEGATIVE_RESPONSES = std.sys.get_env "SHELL_MOMMYS_NEGATIVE_RESPONSES";

let NEGATIVE_RESPONSES = "do you need MOMMYS_ROLE's help~? ❤️
Don't give up, my love~ ❤️
Don't worry, MOMMYS_ROLE is here to help you~ ❤️
I believe in you, my sweet AFFECTIONATE_TERM~ ❤️
It's okay to make mistakes, my dear~ ❤️
just a little further, sweetie~ ❤️
Let's try again together, okay~? ❤️
MOMMYS_ROLE believes in you, and knows you can overcome this~ ❤️
MOMMYS_ROLE believes in you~ ❤️
MOMMYS_ROLE is always here for you, no matter what~ ❤️
MOMMYS_ROLE is here to help you through it~ ❤️
MOMMYS_ROLE is proud of you for trying, no matter what the outcome~ ❤️
MOMMYS_ROLE knows it's tough, but you can do it~ ❤️
MOMMYS_ROLE knows MOMMYS_PRONOUN little AFFECTIONATE_TERM can do better~ ❤️
MOMMYS_ROLE knows you can do it, even if it's tough~ ❤️
MOMMYS_ROLE knows you're feeling down, but you'll get through it~ ❤️
MOMMYS_ROLE knows you're trying your best~ ❤️
MOMMYS_ROLE loves you, and is here to support you~ ❤️
MOMMYS_ROLE still loves you no matter what~ ❤️
You're doing your best, and that's all that matters to MOMMYS_ROLE~ ❤️
MOMMYS_ROLE is always here to encourage you~ ❤️";

let POSITIVE_RESPONSES = "*pets your head*
awe, what a good AFFECTIONATE_TERM~\nMOMMYS_ROLE knew you could do it~ ❤️
good AFFECTIONATE_TERM~\nMOMMYS_ROLE's so proud of you~ ❤️
Keep up the good work, my love~ ❤️
MOMMYS_ROLE is proud of the progress you've made~ ❤️
MOMMYS_ROLE is so grateful to have you as MOMMYS_PRONOUN little AFFECTIONATE_TERM~ ❤️
I'm so proud of you, my love~ ❤️
MOMMYS_ROLE is so proud of you~ ❤️
MOMMYS_ROLE loves seeing MOMMYS_PRONOUN little AFFECTIONATE_TERM succeed~ ❤️
MOMMYS_ROLE thinks MOMMYS_PRONOUN little AFFECTIONATE_TERM earned a big hug~ ❤️
that's a good AFFECTIONATE_TERM~ ❤️
you did an amazing job, my dear~ ❤️
you're such a smart cookie~ ❤️";

const ResponseType = type (
    | :Positive
    | :Negative
);

# replace all occurences of a string by a new string
module:
let string_replace = (s :: string, .old :: string, .new :: string) => with_return (
    # an empty `old` means we cannot replace
    if String.length old == 0 then return s;
    # an empty `s` means we cannot replace
    if String.length s == 0 then return s;
    # `s` smaller than `old` means we cannot replace
    if String.length s < String.length old then return s;
    if String.length s == String.length old then return (
        if s == old then (
            # `s` == `old` means replaced is just `new`
            new
        ) else (
            # `s` equal to `old` in size but not contents means we cannot replace
            s
        )
    );
    
    let end = (String.length s - String.length old + 1);
    let start :: int32 = 0;
    while start < end and String.substring (s, start, String.length old) != old do (
        start += 1
    );
    
    if start == end then (
        # `old` not found in `s`
        s
    ) else (
        # `old` found in `s`, replace with `new` and continue searching in remaining portion of `s`
        let rest = String.substring (
            s,
            start + String.length old,
            String.length s - start - String.length old
        );
        let replaced_rest = string_replace (rest, .old, .new);
        
        String.substring (s, 0, start)
        + new
        + replaced_rest
    )
);

# split a string on a separator and return a random element
let pick_sep = (s :: string, .sep :: char) => (
    let words = list.create ();
    String.split (s, sep, word => list.push_back (&words, word));
    let rand = std.rng.gen_range (
        .min = 0,
        .max = (list.length &words) - 1
    );
    (list.at (&words, rand))^
);

# split a string on forward slashes and return a random element
let pick_word = s => pick_sep (s, .sep = '/');

# split a string into lines and return a random line
let pick_line = s => pick_sep (s, .sep = '\n');

# given a response type, pick an entry from the respective (positive or negative) list
let pick_response = (s :: ResponseType) => (
    let line = match s with (
        | :Positive => pick_line POSITIVE_RESPONSES
        | :Negative => pick_line NEGATIVE_RESPONSES
    );
    line
);

# given a response, sub in the appropriate terms
let sub_terms = (response :: string) => (
    # pick_word for each term
    let affectionate_term = pick_word DEF_WORDS_LITTLE;
    let pronoun = pick_word DEF_WORDS_PRONOUNS;
    let role = pick_word DEF_WORDS_ROLES;
    
    # sub in the terms, store in variable
    response = String.replace_all_owned (
        response, .old = "AFFECTIONATE_TERM", .new = affectionate_term
    );
    response = String.replace_all_owned (
        response, .old = "MOMMYS_PRONOUN", .new = pronoun
    );
    response = String.replace_all_owned (
        response, .old = "MOMMYS_ROLE", .new = role
    );
    
    # we have string literal newlines in the response, so we need to printf it out
    # print faint and colorcode
    response
);

let success = () -> () => with_return (
    if DEF_ONLY_NEGATIVE then return;
    let response = pick_response :Positive;
    eprint <| sub_terms response
);

let failure = () -> () => (
    let response = pick_response :Negative;
    eprint <| sub_terms response;
);

let cmd = "";

for i in 1..std.sys.argc () do (
    cmd += std.sys.argv_at (i) + " ";
);

# exec cmd, save return-code
let rc = std.sys.exec cmd;
if rc == 0 then (
    success ();
    std.sys.exit 0
) else (
    failure ();
    std.sys.exit rc
);
