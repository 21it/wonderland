FROM elixir:1.10.2

WORKDIR /app

COPY . .

RUN cd / && \
    mix do local.hex --force, local.rebar --force && \
    mix archive.install github heathmont/ex_env tag v0.2.2 --force && \
    cd /app # && \
    # rm -rf ./_build/ && \
    # echo "Compressing static files..." && \
    # mix phx.digest && \
    # MIX_ENV=prelive mix compile.protocols && \
    # MIX_ENV=prod    mix compile.protocols && \
    # MIX_ENV=qa      mix compile.protocols && \
    # MIX_ENV=staging mix compile.protocols

CMD echo "Checking system variables..." && \
    scripts/show-vars.sh \
      "MIX_ENV" \
      "ERLANG_OTP_APPLICATION" \
      "ERLANG_HOST" \
      "ERLANG_MIN_PORT" \
      "ERLANG_MAX_PORT" \
      "ERLANG_MAX_PROCESSES" \
      "ERLANG_COOKIE" && \
    scripts/check-vars.sh "in system" \
      "MIX_ENV" \
      "ERLANG_OTP_APPLICATION" \
      "ERLANG_HOST" \
      "ERLANG_MIN_PORT" \
      "ERLANG_MAX_PORT" \
      "ERLANG_MAX_PROCESSES" \
      "ERLANG_COOKIE" && \
    # echo "Running ecto create..." && \
    # mix ecto.create && \
    # echo "Running ecto migrate..." && \
    # mix ecto.migrate && \
    # echo "Running ecto seeds..." && \
    # mix run priv/repo/seeds.exs && \
    echo "Running app..." && \
    elixir \
      --name "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \
      --cookie "$ERLANG_COOKIE" \
      --erl "+K true +A 32 +P $ERLANG_MAX_PROCESSES" \
      --erl "-kernel inet_dist_listen_min $ERLANG_MIN_PORT" \
      --erl "-kernel inet_dist_listen_max $ERLANG_MAX_PORT" \
      -pa "_build/$MIX_ENV/lib/wonderland/consolidated/" \
      -S mix run \
      --no-halt
