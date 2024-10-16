#!/bin/bash

apt-get update
apt install -y docker.io
docker run -d -p 8443:8443 ygalidan/bottelegram:v1.0.1