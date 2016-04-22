-module(test).
-export([start/0]).

start()->
	register(salle1,spawn(test,salle,[])),
	register(salle2,spawn(test,salle,[])),
	register(salle3,spawn(test,salle,[])),
	register(salle4,spawn(test,salle,[])),
	register(salle5,spawn(test,salle,[])),
	register(salle6,spawn(test,salle,[])),
	register(salle7,spawn(test,salle,[])),
	register(salle8,spawn(test,salle,[])),
	register(salle9,spawn(test,salle,[])),

	register(robot1,spawn(test,robot,[self(),salle1])),
	register(robot3,spawn(test,robot,[self(),salle3])),
	register(robot7,spawn(test,robot,[self(),salle7])),


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

salle() ->
	receive
	    {X,demande} -> X!ok,
			   receive
			       libere -> salle()
			   end;
	    fin -> ok
			       
	end.

robot(X,Salle)->
       Salle!{self(),demande}.

