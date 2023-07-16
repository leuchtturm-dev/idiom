Definitions.

Whitespace = [\s\n\t]
Variable   = n|i|f|t|v|w|e
And        = and
Or         = or
Equals     = =
NotEquals  = !=
Modulo     = %
Tilde      = ~
Comma      = ,
Range      = \.\.
Ellipsis   = …|\.\.\.
Integer    = [0-9]+([c][0-9]+)?
Decimal    = [0-9]+(\.[0-9]+([c][0-9]+)?)
Examples   = @.*

Rules.

{Variable}               : {token, {variable, TokenLine, TokenChars}}.
{And}                    : {token, {and_op, TokenLine, TokenChars}}.
{Or}                     : {token, {or_op, TokenLine, TokenChars}}.
{Equals}                 : {token, {equals, TokenLine, TokenChars}}.
{NotEquals}              : {token, {not_equals, TokenLine, TokenChars}}.
{Modulo}                 : {token, {modulo_op, TokenLine, TokenChars}}.
{Tilde}                  : {token, {tilde, TokenLine, TokenChars}}.
{Comma}                  : {token, {comma, TokenLine, TokenChars}}.
{Range}                  : {token, {range_op, TokenLine, TokenChars}}.
{Ellipsis}               : {token, {ellipsis, TokenLine, TokenChars}}.
{Integer}                : {token, {integer, TokenLine, integer_exponent(TokenChars)}}.
{Decimal}                : {token, {decimal, TokenLine, decimal_exponent(TokenChars)}}.
{Examples}               : skip_token.
{Whitespace}+            : skip_token.

Erlang code.

-import('Elixir.Decimal', [new/1]).

integer_exponent(Chars) ->
  case string:split(Chars, "c") of
    [I, E] ->
      Exp = list_to_integer(E),
      Int = list_to_integer(I),
      {Int * trunc(math:pow(10, Exp)), Exp};
    [I] ->
      list_to_integer(I)
  end.

decimal_exponent(Chars) ->
  case string:split(Chars, "c") of
    [F, E] ->
      Exp = list_to_integer(E),
      Decimal_chars = lists:flatten([F, "e", E]),
      Decimal = 'Elixir.Decimal':new(list_to_binary(Decimal_chars)),
      {Decimal, Exp};
    [F] ->
      'Elixir.Decimal':new(list_to_binary(F))
  end.
