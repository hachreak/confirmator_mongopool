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
%%% @doc Application backend behaviour.
%%% @end

-module(confirmator_mongopool_tests).

-include_lib("eunit/include/eunit.hrl").

confirmator_mongopool_test_() ->
    {foreach,
        fun start/0,
        fun stop/1,
        [
             fun generate_ok_auto_test/1,
             fun generate_wrong_token_auto_test/1,
             fun generate_ok_test/1,
             fun generate_wrong_token_test/1
            ]
      }.

%%%===================================================================
%%% Setup/teardown
%%%===================================================================

start() ->
  application:set_env(mongopool, pools,
                      [
                       {testpool, [
                                   {size, 10},
                                   {max_overflow, 30}
                                  ], [
                                      {database, <<"test_db">>},
                                      {host, localhost}
                                     ]}
                      ]),
  application:set_env(confirmator, backend, confirmator_mongopool),
  application:ensure_all_started(confirmator_mongopool),
  {ok, AppCtx} = confirmator_mongopool:init(
                   testpool, test_confirmation_table),
  AppCtx.

stop(_State) ->
    ok.

generate_ok_auto_test(AppCtx) ->
  fun() ->
      Id = <<"test-generate-ok-id">>,

      {ok, {NewAppCtx, Token}} = confirmator:register(Id, AppCtx),
      ?assertEqual({true, AppCtx}, confirmator:confirm(Id, Token, NewAppCtx))
  end.

generate_wrong_token_auto_test(AppCtx) ->
  fun() ->
      Id = <<"test-generate-wrong-token-id">>,

      {ok, {AppCtx, Token}} = confirmator:register(Id, AppCtx),
      WrongToken = << Token/binary, <<"test-wrong-token">>/binary >>,
      ?assertEqual({false, AppCtx},
                   confirmator:confirm(Id, WrongToken, AppCtx)),
      ?assertEqual({false, AppCtx}, confirmator:confirm(Id, Token, AppCtx))

  end.
generate_ok_test(AppCtx) ->
  fun() ->
      Id = <<"test-generate-ok-id">>,
      Token = <<"test-generate-ok-token">>,

      {ok, {AppCtx, Token}} = confirmator:register(Id, Token, AppCtx),
      ?assertEqual({true, AppCtx}, confirmator:confirm(Id, Token, AppCtx))
  end.

generate_wrong_token_test(AppCtx) ->
  fun() ->
      Id = <<"test-generate-wrong-token-id">>,
      Token = <<"test-generate-wrong-token-token">>,
      WrongToken = <<"test-wrong-token">>,

      {ok, {AppCtx, Token}} = confirmator:register(Id, Token, AppCtx),
      ?assertEqual({false, AppCtx},
                   confirmator:confirm(Id, WrongToken, AppCtx)),
      ?assertEqual({false, AppCtx}, confirmator:confirm(Id, Token, AppCtx))
  end.
