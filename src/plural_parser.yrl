Terminals
    and_op
    comma
    equals
    in
    integer
    modulo_op
    not_equals
    not_op
    or_op
    range_op
    variable.

Nonterminals
    and_condition
    condition
    expression
    plural_rule
    range
    range_list
    range_or_value
    relation
    value.

Rootsymbol plural_rule.

Right     100   modulo_op.
Nonassoc  200   equals not_equals.
Left      300   and_op.
Left      400   or_op.

plural_rule       ->  condition          : '$1'.

condition         ->  and_condition or_op condition : or_ast('$1', '$3').
condition         ->  and_condition                 : '$1'.

and_condition     ->  relation and_op and_condition : and_ast('$1', '$3').
and_condition     ->  relation                      : '$1'.

relation          ->  expression not_equals range_list  : not_ast(conditional_ast(equals, '$1', '$3')).
relation          ->  expression equals range_list : conditional_ast(equals, '$1', '$3').
relation          ->  expression not_op in range_list   : not_ast(conditional_ast(equals, '$1', '$4')).

expression        ->  variable modulo_op value : mod_ast('$1', '$3').
expression        ->  variable                 : variable_ast('$1').

range_list        ->  range_or_value comma range_list : append('$1', '$3').
range_list        ->  range_or_value                  : '$1'.

range_or_value    ->  range : '$1'.
range_or_value    ->  value : '$1'.

range             ->  value range_op value : range_ast('$1', '$3').

value             ->  integer : unwrap('$1').

Erlang code.

unwrap({_,_,V}) -> V.

atom(Token) ->
  list_to_atom(unwrap(Token)).

append(A, B) when is_list(B) ->
  [A] ++ B;
append(A, B) when not is_list(B) ->
  [A, B].

variable_ast(Variable) ->
  {atom(Variable), [], nil}.

not_ast(A) ->
  {'!', [], [A]}.

and_ast(A, B) ->
  {'and', [], [A, B]}.

or_ast(A, B) ->
  {'or', [], [A, B]}.

mod_ast(Variable, Value) ->
  {'mod', [], [variable_ast(Variable), Value]}.

range_ast(Start, End) ->
  {'..', [], [Start, End]}.

conditional_ast(equals, A, B = {'..', _, _}) ->
  {'in?', [], [A, B]};
conditional_ast(equals, A, B) ->
  {'==', [], [A, B]}.
