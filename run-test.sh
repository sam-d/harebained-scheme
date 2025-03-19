#!/usr/bin/env bash
echo -e "\033[01;35mTesting Chez\033[00m"
bash tests/test-chez.sh
echo -e "\033[01;35mTesting Guile\033[00m"
bash tests/test-guile.sh
echo -e "\033[01;35mTesting Racket\033[00m"
bash tests/test-racket.sh
