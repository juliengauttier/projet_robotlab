-module(aze).
-export([robotCommuniqueExploration/4,start/0,robot/3,salle/7,maxDistVoisinAux/2,maxDistVoisin/1,reatribDistVoisin/3,explore/2,sendNotifVoisinUpdate/5,sendNotifVoisinUpdateAux/5,reorderSalle/5,majDistanceVoisin/4,
getChemin/4,getCheminAux/5,guessNewDist/4,choisirChemin/5,faireTraverserRobot/4,cheminSortie/2,cheminSortieAux/3,finDetection/3,robotDemandeChemin/3,porteVersVoisinCommunicant/3,
unregisterIfPresentInListAux/2,unregisterIfPresentInList/1,comptageSalleRetirer/2]).

start() ->
	robotlab:reset(),
	register(mainproc,self()),
	register(salle1,spawn(aze,salle,[salle1,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle2,spawn(aze,salle,[salle2,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle3,spawn(aze,salle,[salle3,[],[true,true,true,true],1,[1,1,1,1],false,false])), 

	register(salle4,spawn(aze,salle,[salle4,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle5,spawn(aze,salle,[salle5,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle6,spawn(aze,salle,[salle6,[],[true,true,true,true],1,[1,1,1,1],false,false])), 

	register(salle7,spawn(aze,salle,[salle7,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle8,spawn(aze,salle,[salle8,[],[true,true,true,true],1,[1,1,1,1],false,false])), 
	register(salle9,spawn(aze,salle,[salle9,[],[true,true,true,true],1,[1,1,1,1],false,false])),


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


	   register(robot1,spawn(aze,robot,[1,salle1,0])),
		%register(robot2,spawn(aze,robot,[2,salle2,0])),
	   register(robot3,spawn(aze,robot,[3,salle3,0])),
	   %register(robot5,spawn(aze,robot,[5,salle5,0])),
	   register(robot7,spawn(aze,robot,[7,salle7,0])),
	   %register(robot8,spawn(aze,robot,[8,salle8,0])),


		finDetection(3,[],false),



	   salle1!fin,
	   salle2!fin,
	   salle3!fin,
	   salle4!fin,
	   salle5!fin,
	   salle6!fin,
	   salle7!fin,
	   salle8!fin,
	   salle9!fin,
		
		unregisterIfPresentInList([mainproc,salle1,salle2,salle3,salle4,salle5,salle6,salle7,salle8,salle9,
			robot1,robot2,robot3,robot4,robot5,robot6,robot7,robot8,robot9]),

	ok.

unregisterIfPresentInList([])->ok;
unregisterIfPresentInList([Proc|RProcs])->
	unregisterIfPresentInListAux(Proc,registered()),
	unregisterIfPresentInList(RProcs).
	
unregisterIfPresentInListAux(_,[])->ok;
unregisterIfPresentInListAux(Proc,[Proc|_])->
	unregister(Proc),
	ok;
unregisterIfPresentInListAux(Proc,[ProcList|RProcList])->
	unregisterIfPresentInListAux(Proc,RProcList).
	
	


finDetection(0,_,ParoleReservee)->ok;
finDetection(N,[],ParoleReservee)->
	receive
		{demandePermissionParler,RobotProc,RobotNum,Salle}->
			if
				ParoleReservee->
					RobotProc ! {reponsePermissionParler,false},
					finDetection(N,[],true);
				true->
					RobotProc ! {reponsePermissionParler,true},
					finDetection(N,[],true)
			end;
		{communicationSalleDebut,Salle}->
			finDetection(N,[Salle],ParoleReservee);
		{communicationSalleFin,Salle}->
			finDetection(N,[],ParoleReservee);
		fin->
			finDetection(N-1,[],ParoleReservee)
	end;
finDetection(N,SalleParlantes,ParoleReservee)->
	receive
		{demandePermissionParler,RobotProc,RobotNum,Salle}->
			if
				ParoleReservee->
					RobotProc ! {reponsePermissionParler,false},
					finDetection(N,SalleParlantes,true);
				true->
					RobotProc ! {reponsePermissionParler,false},
					finDetection(N,SalleParlantes,true)
			end;
		{communicationSalleDebut,Salle}->
			finDetection(N,[Salle|SalleParlantes],ParoleReservee);
		{communicationSalleFin,Salle}->
			finDetection(N,comptageSalleRetirer(Salle,SalleParlantes),not(comptageSalleRetirer(Salle,SalleParlantes)==[]));
		fin->
			finDetection(N-1,SalleParlantes,ParoleReservee)
	end.

comptageSalleRetirer(Salle,[])->[];
comptageSalleRetirer(Salle,[Salle|SR])->comptageSalleRetirer(Salle,SR);
comptageSalleRetirer(Salle,[S|SR])->[S|comptageSalleRetirer(Salle,SR)].
	

%% Pos : 0 coin haut gauche, 1 coin bas gauche, 2 coin bas droite, 3 coin haut droite 
robot(RobotNum, Salle, Pos) ->
	   Salle ! {self(),demande},  
	   receive 
			  {reponseDemande,true,true} ->
					 ok;
			  {reponseDemande,true,false} ->
					 ok; 
			  {reponseDemande,false,true} -> 
			  		robotDemandeChemin(RobotNum, Salle, Pos),
					 ok;
			  {reponseDemande,false,false}->
					 ExplorationResultat = explore(RobotNum,Pos),
					 robotCommuniqueExploration(RobotNum,Salle,Pos,ExplorationResultat),					 
					 robotDemandeChemin(RobotNum, Salle, Pos),
					 ok
	   end.
		
robotCommuniqueExploration(RobotNum,Salle,Pos, ExplorationResultat)->
	mainproc ! {demandePermissionParler,self(),RobotNum,Salle},
	receive
		{reponsePermissionParler,true}->
			Salle ! {exploration,ExplorationResultat};

		{reponsePermissionParler,false}->
			robotCommuniqueExploration(RobotNum,Salle,Pos,ExplorationResultat)		
	end.
		
robotDemandeChemin(RobotNum, Salle, Pos) ->
		Salle ! {demandeChemin,self()},
		receive
			{reponseChemin,ListeCheminPossible}->
				choisirChemin(RobotNum,Salle,Pos,ListeCheminPossible,ListeCheminPossible);
			{reponseCheminSortie,CheminSortie}->
				choisirChemin(RobotNum,Salle,Pos,CheminSortie,CheminSortie)
		end.

choisirChemin(RobotNum,AncienneSalle,Pos,ListFull,[])->
	robotDemandeChemin(RobotNum, AncienneSalle, Pos);
	
choisirChemin(RobotNum,AncienneSalle,Pos,ListFull,[{salle0,PosToGo}|LR])->
					NewPos = faireTraverserRobot(RobotNum,Pos,PosToGo,salle0),
					AncienneSalle ! {self(),libere};
choisirChemin(RobotNum,AncienneSalle,Pos,ListFull,[{Voisin,PosToGo}|LR])->
	Voisin ! {demanderLibre,RobotNum,self()},

	receive	   
		{reponseLibre,EstLibre}->
			if
				EstLibre->
					NewPos = faireTraverserRobot(RobotNum,Pos,PosToGo,Voisin),
					AncienneSalle ! {self(),libere},
					robot(RobotNum,Voisin,NewPos);
				true ->
					choisirChemin(RobotNum,AncienneSalle,Pos,ListFull,LR)
			end			
	end.
	
faireTraverserRobot(RobotNum,PosToGo,PosToGo,salle0)->
	R=robotlab:get_robot(RobotNum),
	robotlab:porte(R),
	robotlab:sort(R),
	mainproc ! fin,
	if
		PosToGo == 0 -> 3;
		PosToGo == 1 -> 0;
		PosToGo == 2 -> 1;
		true -> 2
	end;
	
faireTraverserRobot(RobotNum,PosToGo,PosToGo,Voisin)->
	R=robotlab:get_robot(RobotNum),
	robotlab:porte(R),
	robotlab:franchit(R),
	if
		PosToGo == 0 -> 3;
		PosToGo == 1 -> 0;
		PosToGo == 2 -> 1;
		true -> 2
	end;
		
faireTraverserRobot(RobotNum,CurrentPos,PosToGo,Voisin)->	
	R=robotlab:get_robot(RobotNum),
	if
		CurrentPos+1 == 4 ->
			NewPos=0;
		true->
			NewPos = CurrentPos+1
	end,
	robotlab:mur(R),
faireTraverserRobot(RobotNum,NewPos,PosToGo,Voisin).
				

salleReservee(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotReserveur,RobotReserveurProc)->
	receive
		{RobotReserveurProc,demande} -> 
			RobotReserveurProc!{reponseDemande,false,Discovered},
			salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,true);
		{miseAJourDistanceVoisin,NomSalleCom,ProcSalleCom,DistCom}->			
			Test = porteVersVoisinCommunicant(NomSalleCom,Voisins,Portes),
			if
				Discovered and not(Test)->
					ProcSalleCom ! {acquittementNotif,Nom},
					salleReservee(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotReserveur,RobotReserveurProc);
				true->ok
			end,
			UpdateDistance = majDistanceVoisin(Voisins,Distances,NomSalleCom, DistCom),
					 
			NewSalleDist = guessNewDist(Voisins,Portes,UpdateDistance,maxDistVoisin(UpdateDistance)),
			if
				NewSalleDist == SalleDist ->
					ProcSalleCom ! {acquittementNotif,Nom},
					FinalDistances = UpdateDistance;
				true ->
					FinalDistances = sendNotifVoisinUpdate(Nom,Portes,Voisins,UpdateDistance,NewSalleDist+1)
			end,
			salleReservee(Nom,Voisins,Portes,NewSalleDist,FinalDistances,Discovered,CouramentVisite,RobotReserveur,RobotReserveurProc);
		{demanderLibre,RobotNum,RobotProc}->
			RobotProc ! {reponseLibre,false},
			salleReservee(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotReserveur,RobotReserveurProc)		
	end.
	
salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite) ->
	receive
			{exploration,PortesNew}->
					 NewDistances = reatribDistVoisin(Voisins,PortesNew,Distances),
					 NewSalleDist = guessNewDist(Voisins,PortesNew,NewDistances,maxDistVoisin(NewDistances)),
					 FinalDistances = sendNotifVoisinUpdate(Nom,PortesNew,Voisins,NewDistances,NewSalleDist+1),			 
					 salle(Nom,Voisins,PortesNew,NewSalleDist,FinalDistances,true,CouramentVisite);
			{voisinsInit,V} ->
					 salle(Nom,V,Portes,SalleDist,Distances,false,CouramentVisite);
			{miseAJourDistanceVoisin,NomSalleCom,ProcSalleCom,DistCom}->									
					Test = porteVersVoisinCommunicant(NomSalleCom,Voisins,Portes),
					if
						Discovered and not(Test)->
							ProcSalleCom ! {acquittementNotif,Nom},
							salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite);
						true->ok
					end,
					 UpdateDistance = majDistanceVoisin(Voisins,Distances,NomSalleCom, DistCom),		 
					 NewSalleDist = guessNewDist(Voisins,Portes,UpdateDistance,maxDistVoisin(UpdateDistance)),
					 if
						NewSalleDist == SalleDist ->
							ProcSalleCom ! {acquittementNotif,Nom},
							FinalDistances = UpdateDistance;
						true ->
							FinalDistances = sendNotifVoisinUpdate(Nom,Portes,Voisins,UpdateDistance,NewSalleDist+1)
					end,
					 salle(Nom,Voisins,Portes,NewSalleDist,FinalDistances,Discovered,CouramentVisite);
			{X,demande} -> 
					X!{reponseDemande,CouramentVisite,Discovered},
					salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,true);
			{X,libere} ->
					 salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,false);
			{demanderLibre,RobotNum,RobotProc}->
				if
					CouramentVisite->
						RobotProc ! {reponseLibre,false},
						salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite);
					true->
						RobotProc ! {reponseLibre,true},
						salleReservee(Nom, Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite,RobotNum,RobotProc)
				end;	
			{demandeChemin,Robot}->
				Sortie = cheminSortie(Voisins,Portes),
				if
					Sortie == []->
						Robot ! {reponseChemin, getChemin(Voisins,Portes,Distances,minDistVoisin(Portes,Distances))};
					true->
						Robot ! {reponseCheminSortie, Sortie}
				end,
				
				salle(Nom,Voisins,Portes,SalleDist,Distances,Discovered,CouramentVisite);
			  fin -> ok			   
	end.

porteVersVoisinCommunicant(VCommunication,[],[])->false;
porteVersVoisinCommunicant(VCommunication,[VCommunication|VR],[true|PR])->true;
porteVersVoisinCommunicant(VCommunication,[V|VR],[P|PR])->porteVersVoisinCommunicant(VCommunication,VR,PR).

cheminSortie(V,P)->cheminSortieAux(V,P,3).
cheminSortieAux([],[],Pos)->[];
cheminSortieAux([salle0|VR],[true|PR],Pos)->[{salle0,Pos}];
cheminSortieAux([V|VR],[P|PR],Pos)->
	if
		Pos == 3 ->
			NewPos = 0;
		true ->
			NewPos = Pos+1
	end,
	cheminSortieAux(VR,PR,NewPos).

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
reatribDistVoisin([V|VR],[false|PR],[D|DR])->[100|reatribDistVoisin(VR,PR,DR)];
reatribDistVoisin([salle0|VR],[true|PR],[D|DR])->[-100000|reatribDistVoisin(VR,PR,DR)];
reatribDistVoisin([V|VR],[true|PR],[D|DR])->[D|reatribDistVoisin(VR,PR,DR)].

minDistVoisin(Portes,Distances)->minDistVoisinAux(Portes,Distances,100).
minDistVoisinAux([],[],Min)->Min;
minDistVoisinAux([true|PR],[D|DR],Min)->
	   if
			  Min > D ->		
					 minDistVoisinAux(PR,DR,D);
			  true ->
					 minDistVoisinAux(PR,DR,Min)
	   end;
minDistVoisinAux([false|PR],[D|DR],Min)->minDistVoisinAux(PR,DR,Min).

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
guessNewDist([V|VR],[true|PR],[D|DR],MinDist)->
	   if
			  D < MinDist ->
					 guessNewDist(VR,PR,DR,D);
			  true ->
					 guessNewDist(VR,PR,DR,MinDist)
	   end;
guessNewDist([V|VR],[false|PR],[D|DR],MinDist)->guessNewDist(VR,PR,DR,MinDist);
guessNewDist([],[],[],MinDist)->MinDist+1.


sendNotifVoisinUpdate(Nom,Portes,Voisins,UpdateDistance,NewSalleDist)->
	mainproc ! {communicationSalleDebut,Nom},
	sendNotifVoisinUpdateAux(Nom,Portes,Voisins,UpdateDistance,NewSalleDist).

sendNotifVoisinUpdateAux(Nom,[],[],[],NewDist)->
	mainproc ! {communicationSalleFin,Nom},
	[];
sendNotifVoisinUpdateAux(Nom,[P|PR],[salle0|VR],[D|DR],NewDist)->
	   [D|sendNotifVoisinUpdateAux(Nom,PR,VR,DR,NewDist)];
sendNotifVoisinUpdateAux(Nom,[true|PR],[V|VR],[D|DR],NewDist)->
	   V ! {miseAJourDistanceVoisin,Nom,self(),NewDist},
		receive 
			{acquittementNotif,V}->
				MajDist = D;
			{miseAJourDistanceVoisin,V,ProcSalleCom,DistCom}->
				MajDist = DistCom,
				V ! {acquittementNotif,Nom}
		end,
	   [MajDist | sendNotifVoisinUpdateAux(Nom,PR,VR,DR,NewDist)];
sendNotifVoisinUpdateAux(Nom,[false|PR],[V|VR],[D|DR],NewDist)->
	[D|sendNotifVoisinUpdateAux(Nom,PR,VR,DR,NewDist)].


majDistanceVoisin([ProcSalleCom|VR],[DistancesOld|DR],ProcSalleCom,DistCom)->[DistCom|majDistanceVoisin(VR,DR,ProcSalleCom,DistCom)];
majDistanceVoisin([VoisinOld|VR],[DistancesOld|DR],ProcSalleCom,DistCom)->[DistancesOld|majDistanceVoisin(VR,DR,ProcSalleCom,DistCom)];
majDistanceVoisin([],[],ProcSalleCom,DistCom)->[].
	   
explore(RobotNum,Pos)->
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
