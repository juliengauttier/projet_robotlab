-module(mondemo).
-export([start/3,test/2,communication/3]).
-import(lists,[map/2,seq/2,concat/1]).
-import(salles,[initProcesses/1]).
-import(io,[format/2]).

find([],_,Def)->Def;
find([{Y,Key}|_],Key,_)->Y;
find([{_,X}|T],Key,Def) when Key =/= X ->find(T,Key,Def).	
	
%Salles : 1 a 9
%Process 0 : l'exterieur
%%[{Robot,Salle}], 1 entier, 12 bits
start(ListORobots, Sortie, Porte) ->
    robotlab:labyrinthe(Sortie, Porte, string:join(map(fun({R,S})->integer_to_list(R-1) end, ListORobots),"")),
    Robots=map( fun({X,_}) -> (robotlab:get_robot(X)) end, ListORobots),
    Salles=map(fun(X) -> {X,find(ListORobots, X, -1)} end, seq(0, 9)),
    Pid=initProcesses(Salles),
	map(fun(P)->spawn(mydemo,test,[P,Pid]) end,Robots).

test(P,PidSalles)->
	topoSalle(P,PidSalles,2).
	
topoSalle(P,PidSalles,S)->
	Pos=1,
    robotlab:porte(P),
	M1 = robotlab:mur(P),
    M2 = robotlab:mur(P),
    M3 = robotlab:mur(P),
    M4 = robotlab:mur(P),
    L=reSalle(M1,M2,M3,M4,Pos),
	%transformer ma liste de boolean en lists d'entier lorsqu'il y a un true
	io:format("~p",L).

reSalle(M1,M2,M3,M4, 1)->[M4,M1,M2,M3];
reSalle(M1,M2,M3,M4, 2)->[M3,M4,M1,M2];
reSalle(M1,M2,M3,M4, 3)->[M2,M3,M4,M1];
reSalle(M1,M2,M3,M4, 0)->[M1,M2,M3,M4].

%% Liste des salles avec leur pid, le numéro de la salle et le message
communication([{N,Pid}|T], NumSalle, Message)->
	[{_,H2}|T]=lists:filter(fun({Num,_})->Num==NumSalle end, [{N,Pid}|T]),
	H2!Message.


