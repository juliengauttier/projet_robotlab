% pour les salles qui sont libres 
salleLibre(Salle, Sorties, Path)->
    receive
	{isEmpty,X}  -> X!{empty,Salle},salleLibre({Salle}, Sorties, Path);
	
	{enter, RobotNum, RobotPid, From} ->  
	    RobotPid!{ok, Salle},
	    lists:foreach(fun(x) -> x!{updateSalle, Salle} end, Sorties),
	    salleOccupee({Salle, RobotNum},[From|Sorties], Path);
% savoir de quel salle il vient 
	{backtrack, RobotNum, RobotPid, From} ->  
	    RobotPid!{ok, Salle},
	    salleOccupee({Salle, RobotNum},[From|Sorties], Path);
	%chemin et pid  du robot 
	{path, RobotPid} ->
	    RobotPid!{Salle, Path},% le robot envoi la salle ou il se trouve et le chemin  	
	    salleLibre(Salle, Sorties, Path);
	
	{updateSalle, _} ->
	    salleLibre(Salle, Sorties, Path+1);
	
	_ -> salleLibre(Salle, Sorties, Path)
    end.   
% fonction pour salle occupé ,
salleOccupee({Salle, Robot}, Sorties, Path)->
    receive
	{isEmpty,X}  -> X!{notEmpty,Salle},salleOccupee({Salle, Robot},Sorties, Path);
	
	{path, RobotPid} ->
	    RobotPid!{Salle, Path},
	    salleOccupee({Salle,Robot}, Sorties, Path);
	
	{free,RobotPid, To} -> 
	    RobotPid!{ok, Salle},
	    salleLibre(Salle, [To|Sorties], Path);
	
	{updateSalle, X} ->
	    salleOccupee({Salle,Robot}, Sorties, Path+1);
	
	
	_ -> salleOccupee({Salle, Robot}, Sorties, Path)
    end.
test(P)->
      robotlab:porte(P).
  
 	%communication(Pid, 1, yolo),
 	%map(fun(P)->spawn(mydemo,test,[P,Pid]) end,Robots)
 
 test(P,PidSalles)->
 	robotlab:porte(P).
 	
 %% Liste des salles avec leur pid, le numéro de la salle et le message
 communication([{N,Pid}|T], NumSalle, Message)->
 	[{_,H2}|T]=lists:filter(fun({Num,_})->Num==NumSalle end, [{N,Pid}|T]),
 	H2!Message.




start(ListORobots, Sortie, Porte) ->
	robotlab:labyrinthe(Sortie, Porte, string:join(map(fun({R,S})->integer_to_list(R-1) end, ListORobots),"")),
	Robots=map( fun({X,_}) -> (robotlab:get_robot(X)) end, ListORobots),
	Salles=map(fun(X) -> {X,find(ListORobots, X, -1)} end, seq(0, 9)),
    Pid=initProcesses(Salles),
	communication(Pid, 1, yolo)
	%map(fun(P)->spawn(mydemo,test,[P,Pid]) end,Robots)
.

test(P,PidSalles)->
	robotlab:porte(P).
	
%% Liste des salles avec leur pid, le numéro de la salle et le message
communication([{N,Pid}|T], NumSalle, Message)->
	[{_,H2}|T]=lists:filter(fun({Num,_})->Num==NumSalle end, [{N,Pid}|T]),
	H2!Message.
