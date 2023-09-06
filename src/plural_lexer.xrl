Definitions.

Whitespace = \s
Variable   = n|i|f|t|v|w|e
And        = and
Or         = or
Equals     = =
NotEquals  = !=
Modulo     = %
Comma      = ,
Range      = \.\.
Integer    = [0-9]+
Examples   = @.+

Rules.

{Variable}               : {token, {variable, TokenLine, TokenChars}}.
{And}                    : {token, {and_op, TokenLine, TokenChars}}.
{Or}                     : {token, {or_op, TokenLine, TokenChars}}.
{Equals}                 : {token, {equals, TokenLine, TokenChars}}.
{NotEquals}              : {token, {not_equals, TokenLine, TokenChars}}.
{Modulo}                 : {token, {modulo_op, TokenLine, TokenChars}}.
{Comma}                  : {token, {comma, TokenLine, TokenChars}}.
{Range}                  : {token, {range_op, TokenLine, TokenChars}}.
{Integer}                : {token, {integer, TokenLine, integer(TokenChars)}}.
{Examples}               : skip_token.
{Whitespace}+            : skip_token.

Erlang code.

integer(Chars) ->
  list_to_integer(Chars).
