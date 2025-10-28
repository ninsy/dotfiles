#!/bin/bash

docker build -t ubuntu-24-ansible-tester .
docker run -v ./setup.yml:/ansible/setup.yml -v ./tasks:/ansible/tasks --rm ubuntu-24-ansible-tester 
