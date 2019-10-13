:- ensure_loaded(library(clpfd)).

% Finds the solution to the puzzle
puzzle_solution(Rows) :-
    line_rule(Rows), % make this a rule to avoid duplication
    transpose(Rows, Columns),
    line_rule(Columns),
    diagonal_rule(Rows),
    maplist(label, Rows).

% rule: check diagonal
% start by removing labels, then initialise check with top-left value
diagonal_rule(Rows) :-
    drop_head(Rows, Values),
    transpose(Values, Columns), % swap to remove row
    drop_head(Columns, Values2),
    nth0(0, Values2, FirstLine), % the column
    nth0(0, FirstLine, Value),
    validate_diagonal(Values2, Value).

% recursive. removes row and column then checks value
validate_diagonal([[Value]], Value). % mactches to bottom-right
validate_diagonal(Lines, Value) :-
    drop_head(Lines, Values),
    transpose(Values, Columns),
    drop_head(Columns, Values2),
    nth0(0, Values2, FirstLine), % the column
    nth0(0, FirstLine, TopLeft),
    TopLeft #= Value,
    validate_diagonal(Values2, Value).
    

% Rule: check rows
line_rule([_|Line]) :-
    validate_lines(Line).

% check the rules one at a time
validate_lines([]).
validate_lines([Line|Lines]) :-
    validate_line(Line),
    validate_lines(Lines).

% validate 1 row
validate_line([Heading|Values]) :-
    all_distinct(Values), % we can use the new func that chops off 1 row and col to do this in a diff rule
    Values ins 1..9,
    (sum(Values, #=, Heading);
    multiply(Values, 1, Heading)).

% list and acc are bound
multiply([], Acc, Product) :-
    Acc #= Product.
multiply([X|Xs], Acc, Product) :-
    Acc2 #= X * Acc,
    multiply(Xs, Acc2, Product).
    
    
    
drop_head([_|Tail], Tail).

test(A,B) :- A =:= B; true.
