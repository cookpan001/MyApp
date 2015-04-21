%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2015 18:16
%%%-------------------------------------------------------------------
-module(myapp_mod_helper).
-author("pzhu").

%% API
-export([log/3, log/4, logdate/0, timestamp/0, microtime/0]).
logdate() ->
  {H, I, S} = time(),
  {Y, M, D} = date(),
  Str = io_lib:format("~B-~2..0B-~2..0B ~2..0B:~2..0B:~2..0B", [Y, M, D, H, I, S]),
  lists:flatten(Str).
timestamp() ->
  {M, S, Micro} = now(),
  Str = io_lib:format("~B~B.~B", [M, S, Micro]),
  StrNew = lists:flatten(Str),
  list_to_float(StrNew).
microtime() ->
  {M, S, _Micro} = now(),
  M*1000000 + S.
log(Module, Line, List)->
  io:format("~s ~s:~B  ~p~n", [logdate(), Module, Line, List]).
log(Module, Line, Format, List)->
  S = lists:flatten(io_lib:format("~s ~s:~B ", [logdate(), Module, Line])),
  S2 = lists:flatten(io_lib:format(Format ++ "~n", List)),
  io:format("~s ~s", [S, S2]).
