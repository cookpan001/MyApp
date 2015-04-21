%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Mar 2015 16:37
%%%-------------------------------------------------------------------
-module(myapp_tcp).
-author("pzhu").
%% API
-export([start/1, start/2, server/2]).

start(Port) ->
  start(Port, 5).
start(LPort, Num) ->
  case gen_tcp:listen(LPort,[{active, false},{packet,2}]) of
    {ok, ListenSock} ->
      start_servers(Num,ListenSock,LPort),
      {ok, Port} = inet:port(ListenSock),
      Port;
    {error,Reason} ->
      {error,Reason}
  end.

start_servers(0,_, _Port) ->
  ok;
start_servers(Num,LS,Port) ->
  spawn(?MODULE,server,[LS, Port]),
  start_servers(Num-1,LS, Port).

server(LS, Port) ->
  case gen_tcp:accept(LS) of
    {ok,S} ->
      io:format("server port: ~p~n", [Port]),
      loop(S),
      server(LS, Port);
    Other ->
      io:format("accept returned ~w - goodbye!~n",[Other]),
      ok
  end.

loop(S) ->
  inet:setopts(S,[{active,once}]),
  receive
    {tcp,S,Data} ->
      process(S, Data),
      loop(S);
    {tcp_closed,S} ->
      io:format("Socket ~w closed [~w]~n",[S,self()]),
      ok
  end.
process(S, Data)->
  io:format("received data: ~p", [Data]),
  gen_tcp:send(S,"goodbye").