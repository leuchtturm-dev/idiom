Definitions.

Whitespace = [\s\n\t]
Variable   = n|i|f|t|v|w|e
And        = and
Or         = or
Equals     = =
NotEquals  = !=
Modulo     = %
Comma      = ,
Range      = \.\.
Integer    = [0-9]+([c][0-9]+)?
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

-import('Elixir.Decimal', [new/1]).

integer(Chars) ->
  case string:split(Chars, "c") of
    [I, E] ->
      Exp = list_to_integer(E),
      Int = list_to_integer(I),
      {Int * trunc(math:pow(10, Exp)), Exp};
    [I] ->
      list_to_integer(I)
  end.
