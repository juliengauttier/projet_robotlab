-module(aze).
-export([start/0,rob1/1,mdr/0,rob3/1,rob7/1,robot/4,salle/7,maxDistVoisinAux/2,maxDistVoisin/1,reatribDistVoisin/3,explore/2,sendNotifVoisinUpdate/3,
choisirCheminRandom/1,askDistance/1,calculChemin/4,reorderSalle/5,majDistanceVoisin/4,
getChemin/4,getCheminAux/5,guessNewDist/4,choisirChemin/6,faireTraverserRobot/3]).

mdr()->ok.

start() ->
	robotlab:reset(),

%	register(salle1,spawn(aze,salle,[salle1,[],[true,true,true,true],0,[0,0,1,1],false,false])), 
%	register(salle2,spawn(aze,salle,[salle2,[],[true,true,true,true],0,[0,1,1,1],false,false])), 
%	register(salle3,spawn(aze,salle,[salle3,[],[true,true,true,true],0,[0,1,1,0],false,false])), 
%
%	register(salle4,spawn(aze,salle,[salle4,[],[true,true,true,true],0,[1,0,1,1],false,false])), 
%	register(salle5,spawn(aze,salle,[salle5,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
%	register(salle6,spawn(aze,salle,[salle6,[],[true,true,true,true],0,[1,1,1,0],false,false])), 
%
%	register(salle7,spawn(aze,salle,[salle7,[],[true,true,true,true],0,[1,0,0,1],false,false])), 
%	register(salle8,spawn(aze,salle,[salle8,[],[true,true,true,true],0,[1,1,0,1],false,false])), 
%	register(salle9,spawn(aze,salle,[salle9,[],[true,true,true,true],0,[1,1,0,0],false,false])),


	register(salle1,spawn(aze,salle,[salle1,[],[true,true,true,true],0,[1,1,1,1],false,false])), 
	register(salle2,spawn(aze,salle,[salle2,[],[true,true,true,true],0,[1,1,1,1],false,false])), 
	register(salle3,spawn(aze,salle,[salle3,[],[true,true,true,true],0,[1,1,1,1],false,false])), 

	register(salle4,spawn(aze,salle,[salle4,[],[true,true,true,true],0,[1,1,1,1],false,false])), 
	register(salle5,spawn(aze,salle,[salle5,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle6,spawn(aze,salle,[salle6,[],[true,true,true,true],0,[1,1,1,1],false,false])), 

	register(salle7,spawn(aze,salle,[salle7,[],[true,true,true,true],0,[1,1,1,1],false,false])), 
	register(salle8,spawn(aze,salle,[salle8,[],[true,true,true,true],0,[1,1,1,1],false,false])), 
	register(salle9,spawn(aze,salle,[salle9,[],[true,true,true,true],0,[1,1,1,1],false,false])),


	   %%voisins des salle dans l'ordre haut / gauche / bas / droite
	   salle1!{voisinsInit,[salle0,salle0,salle4,salle2]},
	   salle2!{voisinsInit,[salle0,salle1,salle5,salle3]},
	   salle3!{voisinsInit,[salle0,salle2,salle6,salle0]},

	   salle4!{voisinsInit,[salle1,salle0,salle7,salle5]},
	   salle5!{voisinsInit,[salle2,salle4,salle8,salle6]},
	   salle6!{voisinsInit,[salle3,salle5,salle9,salle0]},

	   salle7!{voisinsInit,[salle4,salle0,salle0,salle8]},
	   salle8!{voisinsInit,[salle5,salle7,salle0,salle9]},
	   salle9!{voisinsInit,[salle6,salle8,salle0,salle0]},


	   register(robot1,spawn(aze,robot,[1,self(),salle1,0])),
	   %%register(robot3,spawn(aze,robot,[3,self(),salle3,0])),
	   %%register(robot7,spawn(aze,robot,[7,self(),salle7,0])),

	   receive
	fin -> ok
	   end,
	   receive
	fin -> ok
	   end,
	   receive
	fin -> ok
	   end,

	   salle1!fin,
	   salle2!fin,
	   salle3!fin,
	   salle4!fin,
	   salle5!fin,
	   salle6!fin,
	   salle7!fin,
	   salle8!fin,
	   salle9!fin,
	ok.
  

%% Pos : 0 coin haut gauche, 1 coin bas gauche, 2 coin bas droite, 3 coin haut droite 
robot(RobotNum,ProcMain, Salle, Pos) ->
	   io:format("Robot ~w : entre dans la salle ~w en position ~w ~n",[RobotNum,Salle,Pos]),
	   Salle ! {self(),demande},  
	   receive 

			  %%reponsedemande CourammentVisite / Discovered
			  {reponseDemande,true,true} ->
					 io:format("Robot ~w :retour1 ~n",[RobotNum]),
					 ok;
			  {reponseDemande,true,false} ->
					 io:format("Robot ~w :retour2 ~n",[RobotNum]); 
			  {reponseDemande,false,true} ->
					 io:format("Robot ~w :retour3 ~n",[RobotNum]),
					 ok;
			  {reponseDemande,false,false}->
			  		io:format("Robot ~w :retour4 (~w) ~n",[RobotNum,Pos]),
					 Salle ! {exploration,explore(RobotNum,Pos)},
					 io:format("Robot ~w : demande chemin ~n",[RobotNum]),
					 Salle ! {demandeChemin,self()},
					 receive
							{reponseChemin,ListeCheminPossible}->
								io:format("Robot ~w : on prend  parmis les chemins : ~w ~n",[RobotNum,ListeCheminPossible]),
								choisirChemin(RobotNum,ProcMain,Salle,Pos,ListeCheminPossible,[])
								%%{Voisin,PosToGo} = random:uniform(length(ListeCheminPossible)),
								%%io:format("Robot ~w : on prend le chemin ~w parmis les chemins : ~w ~n",[RobotNum,X,ListeCheminPossible])
					 end,
					 io:format("retour4 ~n"),
					 ok
	   end.

choisirChemin(RobotNum,ProcMain,AncienneSalle,Pos,ListFull,[])->
	choisirChemin(RobotNum,ProcMain,AncienneSalle,Pos,ListFull,ListFull);
choisirChemin(RobotNum,ProcMain,AncienneSalle,Pos,ListFull,[{Voisin,PosToGo}|LR])->
	Voisin ! {demanderLibre,self()},
	%io:format("~n~nDEBUG Robot ~w : attend la reponse de demanderlibre vers ~w ~n",[RobotNum,Voisin]),
	receive	   
		{reponseLibre,EstLibre}->
			if
				EstLibre->
					%io:format("~n~nDEBUG Robot ~w : la salle est libre, on traverse de ~w a ~w ~n~n",[RobotNum,Pos,PosToGo]),
					NewPos = faireTraverserRobot(RobotNum,Pos,PosToGo),
					%io:format("~n~nDEBUG2 Robot ~w : on a parcouru le chemin, la newPos finale vaut ~w",[RobotNum,NewPos]),
					io:format("~n Robot ~w : libere son ancienne salle ~w ~n",[RobotNum,AncienneSalle]),
					AncienneSalle ! libere,
					robot(RobotNum,ProcMain,Voisin,NewPos);
				true ->
					io:format("~n~nDEBUGTest Robot ~w : la salle n'est PAS libre ~n~n",[RobotNum]),

					choisirChemin(RobotNum,ProcMain,AncienneSalle,Pos,ListFull,LR)
			end			
	end.

faireTraverserRobot(RobotNum,PosToGo,PosToGo)->
	R=robotlab:get_robot(RobotNum),
	robotlab:porte(R),
	robotlab:franchit(R),
	if
		PosToGo == 0 -> 3;
		PosToGo == 1 -> 0;
		PosToGo == 2 -> 1;
		true -> 2
	end;
		
faireTraverserRobot(RobotNum,CurrentPos,PosToGo)->	
	R=robotlab:get_robot(RobotNum),
	if
		CurrentPos+1 == 4 ->
			NewPos=0;
		true->
			NewPos = CurrentPos+1
	end,
	robotlab:mur(R),
	%io:format("~n~nDEBUG Robot ~w : newPos ~w  ///  posToGo ~w ~n",[RobotNum,NewPos,PosToGo]),
	faireTraverserRobot(RobotNum,NewPos,PosToGo).
				

choisirCheminRandom([C|CR])->
	   ok.


salleReservee(Nom, Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotReserveur)->
				 %io:format("~n~n~w : reservee par ~w ~n",[Nom,RobotReserveur]),

	receive
		{RobotReserveur,demande} -> 
			io:format("~w : le robot qui a reservee entre(~w), on lui envoie false / ~w ~n",[Nom,RobotReserveur,Discovered]),
			RobotReserveur!{reponseDemande,false,Discovered},
			salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,true);
		{demanderLibre,RobotProc}->
			io:format("~w : le robot ~w demande si libre mais la salle est deja reservee ~n",[Nom,RobotProc]),
			RobotProc ! {reponseLibre,false},
			salleReservee(Nom, Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotReserveur)
			
	end.
	
salle(Nom, Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite) ->
	io:format("~w : debut de fonction ~w // ~w // ~w  // ~w ~n",[Nom,SalleDist,Distances,Discovered,CouramentVisite]),

	receive
			{demanderLibre,RobotProc}->
				io:format("~w : le robot ~w demande si libre (~w) ~n",[Nom,RobotProc,CouramentVisite]),
				if
					CouramentVisite->
						RobotProc ! {reponseLibre,false};
					true->
						RobotProc ! {reponseLibre,true},
						salleReservee(Nom, Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotProc)
				end;
			{voisinsInit,V} ->
					 salle(Nom,V,Portes,SalleDist,Distances,false,CouramentVisite);
			{miseAJourDistanceVoisin,NomSalleCom,ProcSalleCom,DistCom}->
											% io:format("~n~nDEBUG ~w :  ~w  // ~w  //   ~w  // ~w ~n~n~n~n",[Nom,Voisins,Distances,NomSalleCom, DistCom]),

					 UpdateDistance = majDistanceVoisin(Voisins,Distances,NomSalleCom, DistCom),
					 
					 NewSalleDist = guessNewDist(Voisins,Portes,UpdateDistance,maxDistVoisin(UpdateDistance)),
					 io:format("~w : MAJ Dist ~w ~w // nouvelle distances : ~w ~n",[Nom,NomSalleCom,DistCom,UpdateDistance]),
					 if
						NewSalleDist < SalleDist ->
							io:format("~w : nouvelle dist (~w vs ~w), on notifie les voisins ~n",[Nom,SalleDist,NewSalleDist]),
							sendNotifVoisinUpdate(Nom,Voisins,NewSalleDist+1);
						true ->
							io:format("~w : nouvelle dist pas inferieur (~w vs ~w), pas besoin de notifier les voisins ~n",[Nom,SalleDist,UpdateDistance])
					end,
					 salle(Nom, Voisins,Portes,NewSalleDist,UpdateDistance,Discovered,CouramentVisite);
			{X,demande} -> X!{reponseDemande,CouramentVisite,Discovered},
					 salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,true);
			{libere} ->
					io:format("~w : est libre ! ~n",[Nom]),
					 salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,false);

			{exploration,PortesNew}->
					 io:format("Retour de l'exploration : ~w pour la salle ~w ~n",[PortesNew,Nom]),
					 NewDistances = reatribDistVoisin(Voisins,PortesNew,Distances),
					 io:format("Suite explo, newdistances ~w, maxist:~w pour la salle ~w ~n",[NewDistances,maxDistVoisin(NewDistances),Nom]),
					 NewSalleDist = guessNewDist(Voisins,PortesNew,NewDistances,maxDistVoisin(NewDistances)),
					 io:format("La nouvelle distance devinée est ~w pour la salle ~w ~n",[NewSalleDist,Nom]),
					 sendNotifVoisinUpdate(Nom,Voisins,NewSalleDist+1),


					 

					 %%calculChemin(Voisins,PortesNew,nil,4), %%4 en guise de INTMAX
					 
					 salle(Nom,Voisins,PortesNew,NewSalleDist,NewDistances,true,CouramentVisite);
			{demandeChemin,Robot}->
		 %io:format("~n~nDEBUG ~w :  ~w  // ~w  //   ~w  // ~w ~n~n~n~n",[Nom,Voisins,Portes,Distances, SalleDist]),

				Robot ! {reponseChemin, getChemin(Voisins,Portes,Distances,SalleDist)},
				io:format("Salle ~w : Demande du chemin du robot ~n",[Nom]),
				salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite);

			  fin -> ok
				   
	end.

getChemin(Voisins,Portes,Distance,DistanceRecherche)->getCheminAux(Voisins,Portes,Distance,DistanceRecherche,3).
getCheminAux([],[],[],DistanceRecherche,Pos)->[];
getCheminAux([V|VR],[true|PR],[DistanceRecherche|DR],DistanceRecherche,Pos)->
	if
		Pos == 3 ->
			NewPos = 0;
		true ->
			NewPos = Pos+1
	end,
	[{V,Pos}| getCheminAux(VR,PR,DR,DistanceRecherche,NewPos)];
	
getCheminAux([V|VR],[P|PR],[D|DR],DistanceRecherche,Pos)->
	if
		Pos == 3 ->
			NewPos = 0;
		true ->
			NewPos = Pos+1
	end,
	getCheminAux(VR,PR,DR,DistanceRecherche,NewPos).
	   
	   

reatribDistVoisin([],[],[])->[];
reatribDistVoisin([V|VR],[false|PR],[D|DR])->[10|reatribDistVoisin(VR,PR,DR)];
reatribDistVoisin([V|VR],[true|PR],[D|DR])->[D|reatribDistVoisin(VR,PR,DR)].




minDistVoisin(Distances)->minDistVoisinAux(Distances,10).
minDistVoisinAux([],Min)->Min;
minDistVoisinAux([D|DR],Min)->
	   if
			  Min > D ->
					 maxDistVoisinAux(DR,D);
			  true ->
					 maxDistVoisinAux(DR,Min)
	   end.


maxDistVoisin(Distances)->maxDistVoisinAux(Distances,0).
maxDistVoisinAux([],Max)->Max;
maxDistVoisinAux([D|DR],Max)->
	   if
			  Max < D ->
					 maxDistVoisinAux(DR,D);
			  true ->
					 maxDistVoisinAux(DR,Max)
	   end.


%%retourne distance en fonction de celle des voisins
guessNewDist([salle0|VR],[true|PR],[D|DR],MinDist)->0;
guessNewDist([V|VR],[true|PR],[D|DR],MinDist)->
	   if
			  D < MinDist ->
					 guessNewDist(VR,PR,DR,D);
			  true ->
					 guessNewDist(VR,PR,DR,MinDist)
	   end;
guessNewDist([V|VR],[false|PR],[D|DR],MinDist)->guessNewDist(VR,PR,DR,MinDist);
guessNewDist([],[],[],MinDist)->MinDist.

sendNotifVoisinUpdate(Nom,[],NewDist)->ok;
sendNotifVoisinUpdate(Nom,[salle0|VR],NewDist)->
	   sendNotifVoisinUpdate(Nom,VR,NewDist);
sendNotifVoisinUpdate(Nom,[V|VR],NewDist)->
	   %io:format("Debug salle ~w, on a les arguments ~w ~w ~n",[Nom,V,NewDist]), 
	   V ! {miseAJourDistanceVoisin,Nom,self(),NewDist},
	   %%io:format("Debug2 salle ~w, on a les arguments ~w  ~n",[Nom,VR]), 
	   sendNotifVoisinUpdate(Nom,VR,NewDist).

majDistanceVoisin([ProcSalleCom|VR],[DistancesOld|DR],ProcSalleCom,DistCom)->[DistCom|majDistanceVoisin(VR,DR,ProcSalleCom,DistCom)];
majDistanceVoisin([VoisinOld|VR],[DistancesOld|DR],ProcSalleCom,DistCom)->[DistancesOld|majDistanceVoisin(VR,DR,ProcSalleCom,DistCom)];
majDistanceVoisin([],[],ProcSalleCom,DistCom)->[].
	   






explore(RobotNum,Pos)->io:format("~w : on explore !~n",[RobotNum]),
	   R=robotlab:get_robot(RobotNum),
	   A = robotlab:mur(R),
	   B = robotlab:mur(R),
	   C = robotlab:mur(R),
	   D = robotlab:mur(R),
	   reorderSalle(A,B,C,D,Pos).

%%  0 hautgauche, 1 basgauche, 2 basdroite, 3 hautdroite 
reorderSalle(A,B,C,D, 0)->[D,A,B,C];
reorderSalle(A,B,C,D, 1)->[C,D,A,B];
reorderSalle(A,B,C,D, 2)->[B,C,D,A];
reorderSalle(A,B,C,D, 3)->[A,B,C,D].





askDistance(V)->1.

%%procSalle, porte
calculChemin([V|VR],[false|PR],nil,Distance)->io:format("Cacul chemin2 ~n"),calculChemin(VR,PR,nil,Distance);
calculChemin([V|VR],[true|PR],nil,Distance)->calculChemin(VR,PR,V,askDistance(V));
calculChemin([V|VR],[true|PR],Pere,Distance)->io:format("Cacul chemin ~n"),ok.


rob1(X) ->
	   salle1!{self(),demande},
	   receive
	ok -> ok
	   end,
	   R=robotlab:get_robot(1),
	   robotlab:led(R),
	   robotlab:mur(R),
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle2!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle1!libere,
	   robotlab:mur(R),
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:sort(R),
	   salle2!libere,
	   X!fin.

rob7(X) ->
	   salle7!{self(),demande},
	   receive
	ok -> ok
	   end,
	   R=robotlab:get_robot(7),
	   robotlab:led(R),
	   robotlab:mur(R),
	   robotlab:mur(R),
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle4!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle7!libere,
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle1!{self(),demande},       
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle4!libere,
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle2!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle1!libere,
	   robotlab:mur(R),
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:sort(R),
	   salle2!libere,
	   X!fin.



rob3(X) ->
	   salle3!{self(),demande},
	   receive
	ok -> ok
	   end,
	   R=robotlab:get_robot(3),
	   robotlab:led(R),
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle6!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle3!libere,
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle5!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle6!libere,
	   robotlab:porte(R),
	   robotlab:led(R),
	   salle2!{self(),demande},
	   receive
	ok -> ok
	   end,
	   robotlab:led(R),
	   robotlab:franchit(R),
	   salle5!libere,
	   robotlab:mur(R),
	   robotlab:porte(R),
	   robotlab:sort(R),
	   salle2!libere,
	   X!fin.
