#!/bin/bash

set -e

script_file="$0"
scripts_dir="$(dirname -- "$script_file")"
export $(cat "$scripts_dir/.env" | xargs)
"$scripts_dir/check-vars.sh" "in scripts/.env file" "ERLANG_HOST" "ERLANG_OTP_APPLICATION" "ERLANG_COOKIE"

iex \
  --name "local-$(date +%s)@$ERLANG_HOST" \
  --cookie "$ERLANG_COOKIE" \
  --erl "+K true +A 32" \
  --erl "-kernel inet_dist_listen_min 9100" \
  --erl "-kernel inet_dist_listen_max 9199" \
  -e ":timer.sleep(5000); Node.connect(:\"$ERLANG_OTP_APPLICATION@$ERLANG_HOST\")" \
  -S mix

# To push local App.Module module bytecode to remote erlang node run
#
# nl(App.Module)
#
