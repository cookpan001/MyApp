%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2015 17:23
%%%-------------------------------------------------------------------
-module(myapp_echo).
-author("pzhu").

%% API
-export([start/0, start/1, loop/1]).
start()->
  myapp_acceptor:start(?MODULE, {7000, ?MODULE, loop}).
start(Port)->
  myapp_acceptor:start(?MODULE, {Port, ?MODULE, loop}).
loop(S) ->
  myapp_mod_helper:log(?MODULE, ?LINE, "running"),
  receive
    {tcp,S,Data} ->
      process(S, Data),
      loop(S);
    {tcp_closed,S} ->
      myapp_mod_helper:log(?MODULE, ?LINE, "Socket ~w closed [~w]~n",[S,self()])
  end.
process(S, Data)->
  myapp_mod_helper:log(?MODULE, ?LINE, "server receive: ~p", [Data]),
  M = "goodbye",
  gen_tcp:send(S,M),
  myapp_mod_helper:log(?MODULE, ?LINE, "server send: ~p", [M]).