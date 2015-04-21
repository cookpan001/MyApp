%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2015 13:41
%%%-------------------------------------------------------------------
-module(myapp_client).
-author("pzhu").

%% API
-export([client/2, loop/3, test/0, test/1]).
%%
%%client
%%
test() ->
  test(1000).
test(N) when N > 0 ->
  spawn(?MODULE, client, [1800, "test"]),
  test(N - 1);
test(0) ->
  void.
client(PortNo,Message) ->
  try
    {ok,Sock} = gen_tcp:connect("localhost",PortNo,[{active,false},{packet,2}]),
    loop(Sock, Message, 100)
  catch
    _:Reason ->
      myapp_mod_helper:log(?MODULE, ?LINE, "client exception: ~p", [Reason])
  end.
loop(S, M, N) when N > 0->
  Message = io_lib:format("~p:~p:~p", [M, node(), N]),
  gen_tcp:send(S,Message),
  {ok, A} = gen_tcp:recv(S,0),
  myapp_mod_helper:log(?MODULE, ?LINE, "client receive: ~p", [A]),
  timer:sleep(10),
  loop(S, M, N - 1);
loop(S, _M, 0) ->
  gen_tcp:close(S).

