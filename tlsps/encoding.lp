&dom{R..D} = start(J) :- job(J), release(J, R), deadline(J, D).
&dom{R..D} = end(J) :- job(J), release(J, R), deadline(J, D).

1 {modeAssign(J, M) : modeAvailable(J, M)} 1 :- job(J).

duration(J, T) :- job(J), modeAssign(J, M), durationInMode(J, M, T).

&sum{end(J); -start(J)} = T :- job(J), duration(J, T).

&sum{start(J)} >= end(K) :- job(J), job(K), precedence(J, K).

&sum{start(J)} = 0 :- job(J), started(J).

1 {workbenchAssign(J, W) : workbenchAvailable(J, W)} 1 :- job(J), workbenchRequired(J).

R {empAssign(J, E) : employeeAvailable(J, E)} R :- job(J), modeAssign(J, M), requiredEmployees(M, R).

R {equipAssign(J, E) : equipmentAvailable(J, E), group(E, G)} R :- job(J), group(_, G), requiredEquipment(J, G, R).

:- job(J), job(K), linked(J, K), empAssign(J, E), not empAssign(K, E).

precedence(J, K), precedence(K, J) :- job(J), job(K), workbenchAssign(J, W), workbenchAssign(K, W), J < K.
precedence(J, K), precedence(K, J) :- job(J), job(K), empAssign(J, E), empAssign(K, E), J < K.
precedence(J, K), precedence(K, J) :- job(J), job(K), equipAssign(J, E), equipAssign(K, E), J < K.

start(J, S) :- job(J), &sum{start(J)} = S, S = R..D, deadline(J, D), release(J, R).
&sum{start(J)} = S :- start(J, S).

#minimize{ 1, E, J, s2 : job(J), empAssign(J, E), not employeePreferred(J, E) }.

#minimize{ 1, E, P, s3 : project(P), empAssign(J, E), projectAssignment(J, P) }.

&sum{delay(J); T} = end(J) :- job(J), due(J, T), &sum{end(J); -T} > 0.
&sum{delay(J)}=0 :- job(J), due(J, T), &sum{end(J); -T} <= 0.
delay(J, T) :- job(J), &sum{delay(J)} = T, T = 0..M, M = #max{D : deadline(J, D)}.
#minimize{ T, J, s4 : delay(J, T), job(J)}.

&dom{0..H} = projectStart(P) :- project(P), horizon(H).
&dom{0..H} = projectEnd(P) :- project(P), horizon(H).
1 {firstJob(J) : job(J), projectAssignment(J, P)} 1 :- project(P).
&sum{projectStart(P)} = start(J) :- firstJob(J), projectAssignment(J, P).
&sum{projectStart(P)} <= start(J) :- job(J), projectAssignment(J, P).
1 {lastJob(J) : job(J), projectAssignment(J, P)} 1 :- project(P).
&sum{projectEnd(P)} = end(J) :- lastJob(J), projectAssignment(J, P).
&sum{projectEnd(P)} >= end(J) :- job(J), projectAssignment(J, P).
&sum{projectEnd(P)-projectStart(P): project(P)} = projectDelay.
projectDelay(D) :- &sum{projectDelay} = D, D = 0..H*C, horizon(H), C = #count{ P : project(P) }.
#minimize{D, s5 : projectDelay(D)}.

#show modeAssign/2.
#show workbenchAssign/2.
#show empAssign/2.
#show equipAssign/2.
#show start/2.