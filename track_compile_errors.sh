#!/usr/bin/env bash
mix clean
mix compile  2>&1  | sed -r "s/\x1B\[[0-9;]*[mK]//g"  > error_todos
