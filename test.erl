-module(test).
-export([start/0,robot/3,salle/4,initSalle/1,explore/1,explore/4]).
-import(robotlab,[mur/1,get_robot/1,led/1,reset/0]).

start()->
	robotlab:reset(),
	register(salle1,spawn(test,initSalle,[1])),
	register(salle2,spawn(test,initSalle,[2])),
	register(salle3,spawn(test,initSalle,[3])),
	register(salle4,spawn(test,initSalle,[4])),
	register(salle5,spawn(test,initSalle,[5])),
	register(salle6,spawn(test,initSalle,[6])),
	register(salle7,spawn(test,initSalle,[7])),
	register(salle8,spawn(test,initSalle,[8])),
	register(salle9,spawn(test,initSalle,[9])),

	register(robot1,spawn(test,robot,[self(),salle1,1])),

	salle1!{[0,salle4,salle2,0],voisins},
	salle2!{[salle1,salle5,salle3e3,0],voisins},
	salle3!{[salle2,salle6,0,0],voisins},
	salle4!{[0,salle7,salle5,salle1],voisins},
	salle5!{[salle4,salle8,salle6,salle2],voisins},
	salle6!{[salle5,salle9,0,salle3],voisins},
	salle7!{[0,0,salle8,salle5],voisins},
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
	
		salle(Num,Voisins,1,false),
		ok
	end.

salle(Num,Voisins,Distance,Robot) ->
	    io:fwrite("pid : ~p je suis la salle ~p, robot : ~p, Distance : ~p ~n",[self(),Num,Robot,Distance]),
	    	receive
	    		{NVoisins,majVoisins} -> 
	    			salle(Num,NVoisins,Distance,Robot),
	    			ok;
	    		{NDistance,majDistance} -> 
	    			salle(Num,Voisins,NDistance,Robot),
	    			ok;
	    		{NRobot,majRobot} -> 
	    			salle(Num,Voisins,Distance,NRobot),
	    			ok
	    	end.

robot(X,Salle,Num)->
	io:fwrite("pid : ~p je suis le robot ~p ~n",[X,Num]),
	X,Salle!{true,majRobot},
	R=robotlab:get_robot(Num),
	robotlab:led(R),
	Voisins = explore(R),
	X,Salle!{2,majDistance},
	ok.

explore(R) -> 
	explore(R,[],0,robotlab:mur(R)).

explore(R,Voisins,3,true) ->
	io:fwrite("porte en ~p ~n",[0]),
	[true|Voisins];
explore(R,Voisins,3,false) ->
	io:fwrite("pas de porte porte en ~p ~n",[0]),
	[false|Voisins];
explore(R,Voisins,X,true) ->
	io:fwrite("porte en ~p ~n",[X]),
	explore(R,[true|Voisins],X+1,robotlab:mur(R));
explore(R,Voisins,X,false)->
	io:fwrite("pas de porte porte en ~p ~n",[X]),
	explore(R,[false|Voisins],X+1,robotlab:mur(R)).







