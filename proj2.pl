% Purpose: Solve a grid-based math puzzle with as search algorithm.
%
% Uses Prolog's constrain logic programming library to transform the game's
% rules into a combinatorial problem for its solution. We use this library
% for arithmatic, membership and combinatorial constraints.
%
% Any cell in the grid must be unique in its row and column, be 1-9, and
% its row and column values must sum or multiply to its associated header
% value. Values down the diagonal must be equal.

% Libraries
:- ensure_loaded(library(clpfd)).

% Finds the solution to the puzzle
puzzle_solution(Rows) :-
    once(Rows), % Only look for one solution
    line_rule(Rows),
    transpose(Rows, Columns),
    line_rule(Columns),
    diagonal_rule(Rows),
    maplist(label, Rows). % Make the values ground

% drops a row and column
inner_grid(Grid, InnerGrid) :-
    drop_head(Grid, RightGrid),
    transpose(RightGrid, Grid2),
    drop_head(Grid2, InnerGrid).

top_left(Grid, Value) :-
    nth0(0, Grid, FirstLine),
    nth0(0, FirstLine, Value).
    
% rule: check diagonal
% start by removing labels, then initialise check with top-left value
diagonal_rule(Grid) :-
    inner_grid(Grid, InnerGrid),
    top_left(InnerGrid, Value),
    validate_diagonal(InnerGrid, Value).

% recursive. removes row and column then checks value
validate_diagonal([[Value]], Value). % mactches to bottom-right
validate_diagonal(Grid, Value) :-
    inner_grid(Grid, InnerGrid),
    top_left(InnerGrid, TopLeft),
    TopLeft #= Value,
    validate_diagonal(InnerGrid, Value).
    
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
multiply([], Acc, Acc).
multiply([X|Xs], Acc, Product) :-
    New_acc #= X * Acc,
    multiply(Xs, New_acc, Product).
    
drop_head([_|Tail], Tail).

