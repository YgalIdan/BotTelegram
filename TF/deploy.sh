#!/bin/bash

apt-get update
apt install -y docker.io
docker run -d --restart always -p 8443:8443 ygalidan/bottelegram:v1.0.3