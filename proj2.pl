% Author: Matthew Lui 993333
% Purpose: Solve a grid-based math puzzle with as search algorithm.
%
% Uses Prolog's constrain logic programming library to transform the game's
% rules into a combinatorial problem for its solution. We use this library
% for arithmatic, membership and combinatorial constraints.
%
% Any cell in the grid must be unique in its row and column, be 1-9, and
% its row and column values must sum or multiply to its associated header
% value. Values down the diagonal must be equal.

% Algorithms are fun!

% Libraries
:- ensure_loaded(library(clpfd)).

% puzzle_solution(+Rows)
% Enforce constraints with CLPFD and search for a single ground solution
puzzle_solution(Rows) :-
    once(Rows), % Only look for one solution
    line_rule(Rows),
    transpose(Rows, Columns),
    line_rule(Columns),
    diagonal_rule(Rows),
    maplist(label, Rows). % Make the values ground

%%% LINE RULE

% line_rule(+Grid)
% Removes the label and enforces the line rules.
line_rule([_|Lines]) :-
    validate_lines(Lines).

% validate_lines(+Grid)
% Recursively validates the grid, one line at a time.
validate_lines([]).
validate_lines([Line|Lines]) :-
    validate_line(Line),
    validate_lines(Lines).

% validate_line(+Line)
% Applies the line rules to Line, in that values are distinct, 1-9 and
% either sum or multiply to their label.
validate_line([Heading|Values]) :-
    all_distinct(Values),
    Values ins 1..9,
    (sum(Values, #=, Heading);
    multiply(Values, 1, Heading)).

% multiply(+List, +Acc, -Product)
% multiply(+List, +Acc, +Product)
% Elements of List multiply together to from Product, starting from Acc. 
multiply([], Acc, Acc).
multiply([X|Xs], Acc, Product) :-
    New_acc #= X * Acc,
    multiply(Xs, New_acc, Product).

%%% DIAGONAL RULE

% diagonal_rule(+Grid)
% Removes the first row and column of Grid and unifies the leading diagonal.
diagonal_rule(Grid) :-
    inner_grid(Grid, InnerGrid),
    top_left(InnerGrid, Value),
    validate_diagonal(InnerGrid, Value).

% validate_diagonal(+Grid, +Value)
% Recursively unifies the leading diagonal of Grid one element at a time,
% removing a row and column on each step until the bottom-right element is
% encountered
validate_diagonal([[Value]], Value).
validate_diagonal(Grid, Value) :-
    inner_grid(Grid, InnerGrid),
    top_left(InnerGrid, TopLeft),
    TopLeft #= Value,
    validate_diagonal(InnerGrid, Value).

% inner_grid(+Grid, -InnerGrid)
% Drops the first row and column of a 2D matrix. InnerGrid is transposed
% relative to Grid.
inner_grid(Grid, InnerGrid) :-
    drop_head(Grid, RightGrid),
    transpose(RightGrid, Grid2),
    drop_head(Grid2, InnerGrid).

% top_left(+Grid, +Value)
% top_left(+Grid, -Value)
% Value is the term in the first row and column of Grid.
top_left(Grid, Value) :-
    nth0(0, Grid, FirstLine),
    nth0(0, FirstLine, Value).

% drop_head(+List, -Tail)
% Tail is the elements remaining in List after its first item is removed.
drop_head([_|Tail], Tail).
