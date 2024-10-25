#!/bin/bash

apt-get update
apt install -y docker.io
docker run -d --restart always ygalidan/yolo5:v1.0.0
