%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Mar 2015 16:15
%%%-------------------------------------------------------------------
-module(myapp_server).
-author("pzhu").
-behaviour(gen_server).
%% API
-export([start_link/0, stop/0]).
%%Callback
-export([init/1, handle_cast/2, handle_call/3, terminate/2, code_change/3, handle_info/2]).
-record(state, {}).
start_link() ->
  process_flag(trap_exit, true),
  case gen_server:start_link({local, ?MODULE}, ?MODULE, [], []) of
    {ok, Pid} ->
      {ok, Pid};
    {error, already_started, Pid} ->
      {ok, Pid};
    Other ->
      Other
  end.
stop() ->
  gen_server:cast(?MODULE, stop).
log(List)->
  io:format("~p", List).
%%%%%%%%%%%%%%%%%%
%%  Callbacks
%%%%%%%%%%%%%%%%%%
init([]) ->
  void.
handle_info(Info, State) ->
  log(Info),
  {noreply, State}.
handle_cast(stop, State) ->
  {stop, normal, State};
handle_cast(Request,State) ->
  log(Request),
  {noreply, State}.
handle_call(Request, From, State) ->
  log([Request, From]),
  {noreply, State}.
terminate(Reason, _State) ->
  log(Reason),
  ok.
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
