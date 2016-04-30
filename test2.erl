-module(test2).
-export([start/0,robot/3,salle/5,initSalle/1,explore/1,explore/4,verifsalle/3,sortir/2]).
-import(robotlab,[mur/1,get_robot/1,led/1,reset/0]).

start()->
	robotlab:reset(),
	register(salle1,spawn(test2,initSalle,[1])),
	register(salle2,spawn(test2,initSalle,[2])),
	register(salle3,spawn(test2,initSalle,[3])),
	register(salle4,spawn(test2,initSalle,[4])),
	register(salle5,spawn(test2,initSalle,[5])),
	register(salle6,spawn(test2,initSalle,[6])),
	register(salle7,spawn(test2,initSalle,[7])),
	register(salle8,spawn(test2,initSalle,[8])),
	register(salle9,spawn(test2,initSalle,[9])),

	register(robot1,spawn(test2,robot,[self(),salle1,1])),
	register(robot3,spawn(test2,robot,[self(),salle3,3])),
	register(robot7,spawn(test2,robot,[self(),salle7,7])),


	salle1!{[0,salle4,salle2,0],voisins},
	salle2!{[salle1,salle5,salle3e3,0],voisins},
	salle3!{[salle2,salle6,0,0],voisins},
	salle4!{[0,salle7,salle5,salle1],voisins},
	salle5!{[salle4,salle8,salle6,salle2],voisins},
	salle6!{[salle5,salle9,0,salle3],voisins},
	salle7!{[0,0,salle8,salle4],voisins},
	salle8!{[salle7,0,salle9,salle5],voisins},
	salle9!{[salle8,0,0,salle6],voisins},

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
initSalle(Num)->
%commentaire
	receive
		{Voisins,voisins} ->

		io:fwrite("pid : ~p je suis la salle ~p, j'ai pour voisins ~p ~n",[self(),Num,Voisins]),
	
		salle(Num,Voisins,1,false,false),
		ok
	end.

salle(Num,Voisins,Distance,Robot,EstVisite) ->
	    io:fwrite("pid : ~p je suis la salle ~p, robot : ~p, Distance : ~p,j'ai pour voisins ~p , je suis visité : ~p ~n",[self(),Num,Robot,Distance,Voisins,EstVisite]),
	    	receive
	    		{NVoisins,majVoisins} -> 
	    			VVoisins = verifsalle(NVoisins,Voisins,[]),
	    			salle(Num,lists:reverse(VVoisins),Distance,Robot,true),
	    			ok;
	    		{majDistance} -> 
	    			salle(Num,Voisins,Distance+1,Robot,EstVisite),
	    			ok;
	    		{NRobot,majRobot} -> 
	    			salle(Num,Voisins,Distance,NRobot,EstVisite),
	    			ok;
	    		{X,demandeVoisins} ->
	    			X!{Voisins,envoiVoisins},
	    			salle(Num,Voisins,Distance,Robot,EstVisite),
	    			ok
	    	end.

verifsalle([],[],Voisins)->Voisins;
verifsalle([true|T],[H2|T2],Voisins) ->
	verifsalle(T,T2,[H2|Voisins]);
verifsalle([false|T],[H2|T2],Voisins) ->
	verifsalle(T,T2,[0|Voisins]).




robot(X,Salle,Num)->
	io:fwrite("pid : ~p je suis le robot ~p ~n",[X,Num]),
	X,Salle!{true,majRobot},
	R=robotlab:get_robot(Num),
	robotlab:led(R),
	Voisins = explore(R),
	X,Salle!{Voisins,majVoisins},
	X,Salle!{majDistance},
	X,Salle!{self(),demandeVoisins},
	receive
		{NVoisins,envoiVoisins} ->
			Nsalle = sortir(R,NVoisins),
			ok
	end,

	robot(X,Nsalle,Num).


sortir(R,[0|T]) ->
	robotlab:mur(R),
	sortir(R,T);

sortir(R,[H|T]) ->
	robotlab:porte(R),
	robotlab:franchit(R),
	H.


explore(R) -> 
	explore(R,[],0,robotlab:mur(R)).
explore(R,Voisins,3,true) ->
	io:fwrite("porte en ~p ~n",[3]),
	lists:append(Voisins,[true]);
explore(R,Voisins,3,false) ->
	io:fwrite("pas de porte porte en ~p ~n",[3]),
	lists:append(Voisins,[false]);
explore(R,Voisins,X,true) ->
	io:fwrite("porte en ~p ~n",[X]),
	explore(R,lists:append(Voisins,[true]),X+1,robotlab:mur(R));
explore(R,Voisins,X,false)->
	io:fwrite("pas de porte porte en ~p ~n",[X]),
	explore(R,lists:append(Voisins,[false]),X+1,robotlab:mur(R)).




