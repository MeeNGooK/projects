#!/bin/bash

# 1. 현재 디렉토리에서 gc_sing.cuf 컴파일
echo "[1/2] 컴파일 중"
nvfortran -o single_lorentz single_lorentz.cuf || { echo "컴파일 실패"; exit 1; }

# 2. 현재 디렉토리에서 gc_sing 실행
echo "[2/2] 실행 중"
./single_lorentz || { echo "실행 실패"; exit 1; }



echo "모든 작업 완료!"
