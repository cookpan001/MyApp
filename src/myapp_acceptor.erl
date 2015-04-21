%%%-------------------------------------------------------------------
%%% @author pzhu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2015 14:33
%%%-------------------------------------------------------------------
-module(myapp_acceptor).
-author("pzhu").
-behaviour(gen_server).
%% API
-export([start/2, stop/0, accept/3]).
%%Callback
-export([init/1, handle_cast/2, handle_call/3, terminate/2, code_change/3, handle_info/2]).
-define(TCP_OPTIONS, [{active,true},binary,{buffer,1024},{backlog,1024},{packet,2},{nodelay,true},{reuseaddr, true}]).
-record(server_state, {}).
start(Name, Loop) ->
  process_flag(trap_exit, true),
  case gen_server:start_link({local, Name}, ?MODULE, [Loop], []) of
    {ok, Pid} ->
      {ok, Pid};
    {error,{already_started,Pid}} ->
      {ok, Pid};
    Other ->
      Other
  end.
stop() ->
  gen_server:cast(?MODULE, stop).
loop(ServerSocket, M, F) ->
  proc_lib:spawn(?MODULE, accept, [ServerSocket, M, F]).
accept(ServerSocket, M, F) ->
  myapp_mod_helper:log(?MODULE, ?LINE, "accepting"),
  case gen_tcp:accept(ServerSocket) of
    {ok, Socket} ->
      loop(ServerSocket, M, F),
      Pid = proc_lib:spawn(M, F, [Socket]),
      gen_tcp:controlling_process(Socket, Pid);
    Others ->
      myapp_mod_helper:log(?MODULE, ?LINE, Others)
  end.
%%%%%%%%%%%%%%%%%%
%%  Callbacks
%%%%%%%%%%%%%%%%%%
init([{Port, M, F}]) ->
  myapp_mod_helper:log(?MODULE, ?LINE, "init begin"),
  case gen_tcp:listen(Port, ?TCP_OPTIONS) of
    {ok, ServerSocket} ->
      loop(ServerSocket, M, F);
    Others ->
      myapp_mod_helper:log(?MODULE, ?LINE, Others)
  end,
  myapp_mod_helper:log(?MODULE, ?LINE, "init finished"),
  {ok, #server_state{}}.
handle_info(Info, State) ->
  myapp_mod_helper:log(?MODULE, ?LINE, Info),
  {noreply, State}.
handle_cast(stop, State) ->
  {stop, normal, State};
handle_cast(Request,State) ->
  myapp_mod_helper:log(?MODULE, ?LINE, Request),
  {noreply, State}.
handle_call(Request, From, State) ->
  myapp_mod_helper:log(?MODULE, ?LINE, [Request, From]),
  {noreply, State}.
terminate(Reason, _State) ->
  myapp_mod_helper:log(?MODULE, ?LINE, Reason),
  ok.
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
