#!/bin/bash

mix compile
mix coveralls.html || open ./cover/excoveralls.html
echo "Coverage report has been generated!"

