#!/usr/bin/env sh

mkdir -p ./out
wget https://www2.informatik.uni-hamburg.de/TGI/renew/4.2/renew4.2base.zip -O ./out/renew4.2base.zip
unzip out/renew4.2base.zip -d ./out/renew42
mv ./out/renew42/*/* ./renew42/
