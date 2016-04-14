%Projet
%
%

:- use_module(library(clpfd)).
:- use_module(library(lists)).

planning(Debuts,Fins):-

	%get # of lessons and list of lessons 
	read_data(cours,[[NbCours]|Cours]),
	
	%get # of teacher and # of half-days
	read_data(profs,[[NbProfs|[NbJour]]|Profs]),
	
	%get # of Salles and # of half-days
	read_data(salles,[[NbSalles|[NbJour2]]|Salles]),
	
	%get # of Salles and # of half-days
	read_data(groupes,[[NbGroup]|Groupes]),
	
	%list begin time for each lesson
	length(Debuts, NbCours),
	
	%list end time for each lesson
	length(Fins, NbCours),
	
	time_values(NbJour,Times),
	
	domainIN(Debuts,Times),
	domainIN(Fins,Times),
	

	listDuree(Cours,ListDuree),
	build(1, NbCours, ListRessource),
	buildId(1,NbCours, ListId),
	

	make_task(Debuts,ListDuree,Fins,ListRessource,ListId, Taches),

	cumulative(Taches,[limit(NbSalles)]),

	maximum(Fin,Fins),
	labeling([], Debuts).
	%minimize(labeling([], Debuts), Fin).

	

domainIN([],Times).
domainIN([X|Xs],Times):- X in Times, domainIN(Xs,Times).



listName([],ListName).
listName([Cour|Cours],[Name|Ns]):-
	last(Cour, Name),
	listName(Cours,Ns).


listDuree([],ListDuree).
listDuree([Cour|Cours],[DureeEnQuart|Ds]):-
	nth0(2,Cour,Duree),
	atom_to_hour(Duree,H,M),
	DureeEnQuart is round((H * 4) + (M /15)),
	listDuree(Cours,Ds).

buildId(X,X,[X|Xs]).
buildId(X,Y,[X|Xs]):-
	Z is X + 1,
	buildId(Z,Y,Xs).





make_task([], [], [], [], [], []).
make_task([T|Ts], [D|Ds], [F|Fs],[R|Rs],[N|Ns], [task(T,D,F,R,N)|Taches]) :-
	make_task(Ts, Ds, Fs, Rs, Ns, Taches).


%Building a list of N elements, each element is X
build(X, N, List)  :-
    length(List, N),
    maplist(=(X), List).




time_values(N, Times):-
	make_dom(1, N, (32..50), Times).



make_dom(N, N, D, D).
make_dom(I1, N, D1, D2) :-
	I1 < N,
	I is I1 + 1,
	(	I mod 2 =:= 0					% Si I est paire
	->	X is (I-1)//2*96 + 54, 			% L'apres midi
		Y is (I-1)//2*96 + 72
	;	X is (I-1)//2*96 + 32,			%le matin
		Y is (I-1)//2*96 + 50
	),
	make_dom(I, N, D1 \/(X..Y), D2).



	/*
 * read_data(File, Data) lit le fichier File et renvoie dans Data
 * la liste des données de chaque ligne du fichier sous forme
 * de nombres et d'atomes
 * Exemple :
 * [[16],[4,4,'2h00',sc,ne,'Statistiques'],...]
 * avec File = 'u:/PPC/Projet/cours'
 */

read_data(File, Data) :-
	open(File, read, F),
	read_lines(F, Data),
	close(F).

read_lines(F, Data) :-
	read_line(F, Codes),          % read_line_to_codes dans SWI-Prolog
	%read_line_to_codes(F, Codes),
	(   Codes = end_of_file
	->  Data = []
	;   codes_to_datas(Codes, L),
	    read_lines(F, Ls),
	    Data = [L|Ls]
	).
select_characters([C|Cs], [C|Ds], Cs1) :-
	(   48 =< C, C =< 57
	;   65 =< C, C =< 90
	;   97 =< C, C =< 122
	),
	!,
	select_characters(Cs, Ds, Cs1).
select_characters(Cs, [], Cs).

codes_to_datas(Cs, L) :-
	(   Cs = []
	->  L = []

	;   (   Cs = [32|Cs1]
	    ->	codes_to_datas(Cs1, L)

	    ;	select_characters(Cs, Ds, Cs1),
		%atom_codes(N, Ds),
		name(N, Ds),
		codes_to_datas(Cs1, Ns),
	        L = [N|Ns]
	    )
	).

/*
 * Pour convertir une heure sous forme d'atome A en heure H et minute M :
 * atom_to_hour(A, H, M)
 */

atom_to_hour(A, H, M) :-
	atom_codes(A, L),
	codes_to_hour(L, H, M).

codes_to_hour(L, H, M) :-
	append(CH, [104|CM], L),
	number_codes(H, CH),
	number_codes(M, CM).



