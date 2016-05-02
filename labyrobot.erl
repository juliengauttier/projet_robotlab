-module(labyrobot).
-export([nord/1, sud/1,ouest/1,est/1,monrobot/1]).
-export([start/3,test/2,communication/3]).
-import(salles,[initProcesses/1]).
-import(io,[format/2]).

nomrobot(N) -> String:concat("robot",integrer_to_list(N))


nord(N) when N<4 -> dehors;
nord(N) -> N-3
sud(N) -> N-3
sud(N) when NS6 -> dehors;
sud(N) when Nrem3 == 1 -> dehors;
ouest(N) -> N-1
est(N) whenNrem3==0->dehors;
est(N) -> N+1

%reconnaissance de la salle

procsSalles([],_,_,Res) -> Res;
procsSalles([dehors/Ts],[_|Tm],[procs,Res) -> procsSalles(Ts,Tm,Lprocs,Res++[dehors]);
procs([Nm|Ts],[_,Tm],LProcs,Res) -> procsSalles (Ts,Tm,Lprocs,Res++[array:getnum-1,Lprocs]).
SortieDirect([],_,_) -> False;
SortieDirect([dehors]|,true|_],N) -> N;

%Algorithme de recherche

envRoute0([],_) -> Ok;
envRoute0([dehors|T],chemin -> envRoute(T,chemin);
envRoute0([Proc|T],chemin) -> 
Proc {route,chemin},
envRoute0(T,chemin),
cheminMeilleur(_,inconnu)-> true;
cheminMeilleur(_,[inconnu]) -> true;
cheminMeilleur(Nouv,Anc) -> length(Nouv) -> length(Anc).

%reçoit la plus bonne route


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

%Start mur de depart, Exit mur d'arrive /!\ le mur d'arrive doit etre une porte /!\
%parametre: int representant la cardinalite du mur Nord=0 Ouest=1 Sud=2 Est=3	
goToDoor(Start, Exit,P) when Start > Exit ->
    walk(4+(Exit-Start),P);
goToDoor(Start, Exit,P) ->
    walk(Exit-Start,P).
   

walk(Dist,P)when Dist==0 -> robotlab:porte(P);
walk(Dist,P) ->
    robotlab:mur(P),
    walk(Dist-1,P).

