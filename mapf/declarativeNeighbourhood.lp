_lns_select(A) :- agent(A).

_lns_fix(exec(A, M, T), A) :- _lns_select(A), exec(A, M, T).
_lns_fix(at(A, X, Y, T), A) :- _lns_select(A), at(A, X, Y, T).
_lns_fix(at_goal(A, T), A) :- _lns_select(A), at_goal(A, T).
_lns_fix(at_goal_back(A, T), A) :- _lns_select(A), at_goal_back(A, T).
_lns_fix(cost(A, T, 1), A) :- _lns_select(A), cost(A, T, 1).
