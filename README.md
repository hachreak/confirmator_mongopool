confirmator mongopool
=====================

[![Build Status](https://travis-ci.org/hachreak/confirmator_mongopool.svg?branch=master)](https://travis-ci.org/hachreak/confirmator_mongopool)

A backend implementation for the OTP library
[confirmator](https://github.com/hachreak/confirmator).

Configuration
-------------

```erlang
[
  {mongopool, [
    {pools, [
      {mypool, [
        {size, 10},
        {max_overflow, 30}
      ], [
        {database, <<"mydb">>},
        {hostname, dbserver},
        {login, "myuser"},
        {password, "mypassword"},
        {w_mode, safe}
      ]}
    ]}
  ]},
  {confirmator, [
    {backend, confirmator_mongopool}
  ]},
  {confirmator_mongopool, [
    {pool, mypool},
    {table, mytable}
  ]}
]
```

Usage
-----

Configure `confirmator` to use this `backend`.

Start the plugin:

```erlang
application:ensure_all_started(confirmator_mongopool).
{ok, AppCtx} = confirmator:init().
```

Or, if want initialize manually the plugin:

```erlang
application:ensure_all_started(confirmator_mongopool).
{ok, AppCtx} = confirmator_mongopool:init(mypool, mytable).
```

To know how to use it, see directly the
[confirmator](https://github.com/hachreak/confirmator) documentation.

Build
-----

    $ rebar3 compile

Tests
-----

    $ ./utils/rebar3 eunit
