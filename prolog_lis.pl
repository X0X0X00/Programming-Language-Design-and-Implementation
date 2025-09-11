/* 
Example: input = [3, 1, 4, 1, 5]
DP = [1-1-[3], 2-1-[1], 3-1-[4], 4-1-[1], 5-1-[5]] #index-length-sequence
    i=1, j=... no update
    i=2, j=1 3<1 false -> no update
    i=3, j=1 3<4 and 1+1>1 -> update dp[3] = 2-[3,4]
         j=2 4>1 true but 1+1>2 false -> no update
    i=4, j=1 1>3 false -> no update 
         j=2 1>1 false -> no update
         j=3 1>4 false ->no update
    i=5, j=1 3<5 and 1+1>1 -> update dp[5] = 2-[3,5]
         j=2 1<5 and 1+1>2 false -> no update
         j=3 4<5 and 2+1>2 -> update dp[5] = 3-[3,4,5]
         j=4 1<5 and 1+1>3 false -> no update

Final DP = [1-1-[3], 2-1-[1], 3-2-[3,4], 4-1-[1], 5-3-[3,4,5]]
Max = [3,4,5]

Time Complexity: O(n²) Space Complexity: O(n²)
*/


/*
if -> :-
and -> ,
stop -> ! 
then -> -> 
else -> ;
end -> .
count length -> length(a, name)
function -> lis(input, output) 
take nth element -> nth1(n, list, element) 
append element to list -> append(list, [element], newlist)
find element in list -> member(element, list)
replace element in list -> replace(element, newelement, list, newlist)
find max in list -> max_by_length(list, maxelement)
loop -> loop_for_i(input_sequence, index, length, list, newlist)
*/

% Function
lis(Sequence, LIS) :-
    length(Sequence, N),
    init_dp(Sequence, 1, DPInit),
    loop_for_i(Sequence, 1, N, DPInit, DPFinal),
    max_by_length(DPFinal, LIS).


% dp = Index-Length-Sequence
init_dp([], _, []). % stop
% def Recursive
init_dp([Head|Tails], Index, [Index-1-[Head]|Result]) :-
    NextIndex is Index + 1,
    init_dp(Tails, NextIndex, Result).


% Outer loop i -> 1...N
loop_for_i(_, I, N, DP, DP) :- I > N, !. % stop DPIN = DPOUT when I > N
% def loop i
loop_for_i(Sequence, I, N, DPIn, DPOut) :-
    loop_for_j(Sequence, I, 1, DPIn, UpdatedDP),
    Next_I is I + 1, % i++
    loop_for_i(Sequence, Next_I, N, UpdatedDP, DPOut).


% Inner loop j -> 1...I-1
loop_for_j(_, I, J, DP, DP) :- J >= I, !. % stop DPIN = DPOUT if J >= I
% def loop j
loop_for_j(Sequence, I, J, DPIn, DPOut) :-
    member(J-LengthJ-SequenceJ, DPIn),      % Find dp[j]: SequenceJ end with ValJ index = J DPIn is a list of dp 
    member(I-LengthI-SequenceI, DPIn),      % Find dp[i]: SequenceI end with ValI index = I DPIn is a list of dp
    nth1(J, Sequence, ValJ), % ValJ = Sequence[j] 
    nth1(I, Sequence, ValI), % ValI = Sequence[i]
    NewLengthI is LengthJ + 1, % NewLengthI = LengthJ + 1

    % if ValJ < ValI and LengthJ + 1 > LengthI then(->)
    ( ValJ < ValI, LengthJ + 1 > LengthI ->
        append(SequenceJ, [ValI], NewSequenceI), % NewSequenceI = SequenceJ + ValI
        replace_dp(I, NewLengthI, NewSequenceI, DPIn, DPNext) % Update dp[i] newelement = (NewLengthI, NewSequenceI)
    ; DPNext = DPIn ), % else(;) DPNext = DPIn
    Next_J is J + 1, % j++
    loop_for_j(Sequence, I, Next_J, DPNext, DPOut).

replace_dp(Index, NewLen, NewSequence, [Index-_-_|Rest], [Index-NewLen-NewSequence|Rest]) :- !. % change when found and stop
replace_dp(Index, NewLen, NewSequence, [Other|Rest], [Other|UpdatedRest]) :- % not found, continue to search
    replace_dp(Index, NewLen, NewSequence, Rest, UpdatedRest).


max_by_length([_-_-Sequence], Sequence):- !. % stop when only one element
% def Recursive
max_by_length([_-Len1-Sequence1, _-Len2-Sequence2|Rest], MaxSequence) :- 
    % compare Len1 and Len2 or Others
    (Len1 >= Len2 ->
        max_by_length([_-Len1-Sequence1|Rest], MaxSequence)
    ;
        max_by_length([_-Len2-Sequence2|Rest], MaxSequence)
    ).


