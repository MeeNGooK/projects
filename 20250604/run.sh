#!/bin/bash

# 2. 현재 디렉토리에서 gc_sing 실행
echo "[1/4] 컴파일 중: gc_multi.cuf"
nvfortran -acc -gpu=cc60,cc70,cc80,cc89 gc_multi.cuf -o run_multi || { echo "run_multi 컴파일 실패"; exit 1; }

echo "[1] 실행 중: ./run_multi"
./run_multi || { echo "run_multi 실행 실패"; exit 1; }
echo "[2] 실행 중: ./run_multi"
./run_multi || { echo "run_multi 실행 실패"; exit 1; }
echo "[3] 실행 중: ./run_multi"
./run_multi || { echo "run_multi 실행 실패"; exit 1; }

echo "[3/4] 컴파일 중: ./f90s/gc_multi.f90"
cd ./f90s || { echo "f90s 디렉토리 없음"; exit 1; }
gfortran gc_multi.f90 -o gc90  || { echo "gc90 컴파일 실패"; exit 1; }
echo "[1] 실행 중: ./gc90"
./gc90 || { echo "gc90 실행 실패"; exit 1; }
echo "[2] 실행 중: ./gc90"
./gc90 || { echo "gc90 실행 실패"; exit 1; }
echo "[3] 실행 중: ./gc90"
./gc90 || { echo "gc90 실행 실패"; exit 1; }
echo "모든 작업 완료!"
