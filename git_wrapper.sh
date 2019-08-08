#!/bin/bash

n=0
until [ $n -ge 5 ]
do
  git $@ && break
  n=$[$n+1]
  sleep 2
done
