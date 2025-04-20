delta(right, X, Y, X+1, Y  ) :- rangeX(X), rangeY(Y).
delta(left,  X, Y, X-1, Y  ) :- rangeX(X), rangeY(Y).
delta(up,    X, Y, X  , Y+1) :- rangeX(X), rangeY(Y).
delta(down,  X, Y, X  , Y-1) :- rangeX(X), rangeY(Y).
delta(wait,  X, Y, X  , Y  ) :- rangeX(X), rangeY(Y).

action(right).
action(left).
action(up).
action(down).
action(wait).

1 {exec(A, M, T-1) : action(M)} 1 :- time(T), agent(A).

at(A, X, Y, T) :- exec(A, M, T-1), at(A, X', Y', T-1), delta(M, X', Y', X, Y).

:- at(A, X, Y, T), not rangeX(X).
:- at(A, X, Y, T), not rangeY(Y).
:- at(A, X, Y, T), obstacle(X, Y).

:- at(A, X, Y, T), at(A', X, Y, T), A != A'. % vertex conflict

:- at(A, X+1, Y  , T-1), at(A', X, Y, T-1), at(A, X, Y, T), at(A', X+1, Y  , T). % horizontal swap conflict
:- at(A, X  , Y+1, T-1), at(A', X, Y, T-1), at(A, X, Y, T), at(A', X  , Y+1, T). % vertical swap conflict

at_goal(A, T) :- at(A, X, Y, T), goal(A, X, Y).
:- agent(A), not at_goal(A,T), time(T), not time(T+1).

at_goal_back(A, T  ) :- agent(A), time(T), not time(T+1).
at_goal_back(A, T-1) :- at_goal_back(A, T), exec(A, wait, T-1).

cost(A, T, 1) :- at(A, X, Y, T), not goal(A, X, Y).
cost(A, T, 1) :- at(A, X, Y, T), goal(A, X, Y), exec(A, M, T), M != wait.
cost(A, T, 1) :- at(A, X, Y, T), goal(A, X, Y), exec(A, wait, T), not at_goal_back(A, T).

#minimize{C, T, A : cost(A, T, C)}.

#show exec/3.
