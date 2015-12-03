%%% @author Leonardo Rossi <leonardo.rossi@studenti.unipr.it>
%%% @copyright (C) 2015 Leonardo Rossi
%%%
%%% This software is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This software is distributed in the hope that it will be useful, but
%%% WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this software; if not, write to the Free Software Foundation,
%%% Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
%%%
%%% @doc This module is used to confirm a object (e.g. confirm user by email).
%%% @end

-module('confirmator_mongopool').

-behaviour(confirmator_backend).

% My API
-export([start/0, start/2, stop/1]).

% Behaviour API
- export([register/3, confirm/3]).


%%% My API Implementation.

start() ->
  {ok, Pool} = application:get_env(confirmator_mongopool, pool),
  {ok, Table} = application:get_env(confirmator_mongopool, table),
  start(Pool, Table).

start(Pool, Table) ->
  application:ensure_all_started(mongopool),
  {ok, #{pool => Pool, table => Table}}.

stop(_AppCtx) ->
  ok.


%%% Behaviour API Implementation.

%% @doc Register the object by its id, associate with a token.
-spec register(confirmator:id(), confirmator:token(),
               confirmator:appctx()) ->
  {ok, confirmator:appctx()} | {error, bad_token}.
register(Id, Token, AppCtx = #{pool := Pool, table := Table}) ->
  mongopool_app:update(Pool, Table,
    #{<<"_id">> => Id}, {<<"$set">>, #{<<"token">> => Token}},
    [{upsert, true}]),
  {ok, AppCtx}.


%% @doc Confirm the object associated with the token. Return true if the token
%%      is valid.
%%      Otherwise, return false.
%%      In any case remove it from the database because it's usable only one
%%      time.
-spec confirm(confirmator:id(), confirmator:token(),
              confirmator:appctx()) -> {boolean(), confirmator:appctx()}.
confirm(Id, Token, AppCtx = #{pool := Pool, table := Table}) ->
  % check token
  Outcome = case mongopool_app:find_one(Pool, Table, #{<<"_id">> => Id}) of
              #{<<"_id">> := Id,
                <<"token">> := Token} -> true;
              #{<<"_id">> := Id, <<"token">> := _WrongToken} -> false;
              #{} -> false
            end,
  % clear the token before exit
  mongopool_app:delete(Pool, Table, #{<<"_id">> => Id}),
  {Outcome, AppCtx}.
