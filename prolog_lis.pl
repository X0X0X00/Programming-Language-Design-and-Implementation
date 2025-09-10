/* 
Example: input = [3, 1, 4, 1, 5]




Time Complexity: O(n³) Space Complexity: O(n²)
*/

/*
if :-
count length length(a, name)
*/



% 输入 Seq, 输出 LIS
lis(Seq, LIS) :-
    length(Seq, N),
    % 初始化 dp: 每个元素一个子序列
    init_dp(Seq, 1, DPInit),
    % 两层循环更新 dp
    update_dp(Seq, 1, N, DPInit, DPFinal),
    % 找最长序列
    max_by_length(DPFinal, LIS).

% 初始化 dp: 每个位置都是 [X]
init_dp([], _, []).
init_dp([X|Xs], I, [I-1-[X]|Rest]) :-
    I1 is I + 1,
    init_dp(Xs, I1, Rest).

% 外层循环 (i 从 1..N)
update_dp(_, I, N, DP, DP) :- I > N, !.
update_dp(Seq, I, N, DPIn, DPOut) :-
    update_for_j(Seq, I, 1, DPIn, DPUpd),  % 内层循环 j
    I1 is I + 1,
    update_dp(Seq, I1, N, DPUpd, DPOut).

% 内层循环 (j 从 1..I-1)
update_for_j(_, _, J, DP, DP) :-
    length(DP, Len),
    J >= Len, !.
update_for_j(Seq, I, J, DPIn, DPOut) :-
    member(J-LenJ-SeqJ, DPIn),      % 找到 dp[j]
    member(I-LenI-SeqI, DPIn),      % 找到 dp[i]
    nth1(J, Seq, ValJ),
    nth1(I, Seq, ValI),
    ( ValJ < ValI, LenJ + 1 > LenI ->
        append(SeqJ, [ValI], NewSeqI),
        replace_dp(I, LenJ+1, NewSeqI, DPIn, DPNext)
    ; DPNext = DPIn ),
    J1 is J + 1,
    update_for_j(Seq, I, J1, DPNext, DPOut).

% 替换 DP[i]
replace_dp(I, NewLen, NewSeq, [I-_-_|Rest], [I-NewLen-NewSeq|Rest]) :- !.
replace_dp(I, NewLen, NewSeq, [Other|Rest], [Other|RestUpd]) :-
    replace_dp(I, NewLen, NewSeq, Rest, RestUpd).

% 找长度最长的序列
max_by_length([_-_-Seq], Seq).
max_by_length([_-Len1-Seq1, _-Len2-Seq2|Rest], MaxSeq) :-
    (Len1 >= Len2 ->
        max_by_length([_-Len1-Seq1|Rest], MaxSeq)
    ;
        max_by_length([_-Len2-Seq2|Rest], MaxSeq)
    ).
