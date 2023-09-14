:- module(main, [is_vote_wasted/2, is_candidate_elected/2, candidate_count_from_city/3, all_parties/1, all_candidates_from_party/2, all_elected_from_party/2, election_rate/2, council_percentage/2, alternative_debate_setups/2]).
:- [kb].
is_vote_wasted(City, PoliticalParty) :-
    \+ elected(City, PoliticalParty, _).
is_candidate_elected(Name, PoliticalParty) :-
    candidate(Name, PoliticalParty, City, Row),
    elected(City, PoliticalParty, ElectedRepresentativeCount),
    Row =< ElectedRepresentativeCount.
candidate_count_from_city([], _, 0).
candidate_count_from_city([H|T], GivenCity, Count) :-
    candidate(H, _, GivenCity, _),
    candidate_count_from_city(T, GivenCity, Count1),
    Count is Count1 + 1.
candidate_count_from_city([H|T], GivenCity, Count) :-
    \+ candidate(H, _, GivenCity, _),
    candidate_count_from_city(T, GivenCity, Count).

all_parties(ListOfPoliticalParties) :-
    findall(PoliticalParty, party(PoliticalParty, _), ListOfPoliticalParties).
all_candidates_from_party(PoliticalParty, ListOfCandidates) :-
    findall(Name, candidate(Name, PoliticalParty, _, _), ListOfCandidates).

all_elected_from_party(PoliticalParty, ListOfCandidates) :-
    findall(Name, (candidate(Name, PoliticalParty, City, Row), elected(City, PoliticalParty, Count), Row =< Count), ListOfCandidates).

election_rate(PoliticalParty, Percentage) :-
    all_candidates_from_party(PoliticalParty, AllCandidates),
    length(AllCandidates, TotalCandidates),
    all_elected_from_party(PoliticalParty, ElectedCandidates),
    length(ElectedCandidates, TotalElected),
    Percentage is TotalElected / TotalCandidates.

council_percentage(PoliticalParty, Percentage) :-
    to_elect(TotalToElect),
    all_elected_from_party(PoliticalParty, ElectedCandidates),
    length(ElectedCandidates, TotalElected),
    TotalToElect > 0, 
    Percentage is TotalElected / TotalToElect.
alternative_debate_setups(DescriptionString, OrderedListOfCandidates) :-
    convert_to_party_initials(DescriptionString, PartyInitials),
    generate_initial_sitting_plan(PartyInitials, InitialSetter),
    find_candidates(InitialSetter, [], [], OrderedListOfCandidates).
    convert_to_party_initials(DescriptionString, PartyInitials) :-
    atom_chars(DescriptionString, PartyInitials).
generate_initial_sitting_plan(PartyInitials, InitialSetter) :-
    sittingplan(3, PartyInitials, InitialSetter).
sittingplan(0, _, []).
sittingplan(L, [X|T], [X|Others]) :- L > 0, L1 is L-1, sittingplan(L1, T, Others).
sittingplan(L, [_|T], Others) :- L > 0, sittingplan(L, T, Others).
find_candidates([], _, OrderedListOfCandidates, OrderedListOfCandidates).
find_candidates([H|T], Selected, Temp, OrderedListOfCandidates) :-
    find_party(H, PoliticalParty),
    find_possible_candidates(PoliticalParty, Selected, PossibleCandidates),
    select_candidate(PossibleCandidates, Candidate),
    add_to_list(Temp, Candidate, NewTemp),
    add_to_list(Selected, Candidate, NewSelected),
    find_candidates(T, NewSelected, NewTemp, OrderedListOfCandidates).
find_party(H, PoliticalParty) :-
    party(PoliticalParty, H).
find_possible_candidates(PoliticalParty, Selected, PossibleCandidates) :-
    findall(Name, (candidate(Name, PoliticalParty, _, _), \+ member(Name, Selected)), PossibleCandidates).
select_candidate(PossibleCandidates, Candidate) :-
    member(Candidate, PossibleCandidates).
add_to_list(List, Item, NewList) :-
    append(List, [Item], NewList).