#!/bin/bash

# 1. 현재 디렉토리에서 gc_sing.cuf 컴파일
echo "[1/4] 컴파일 중: gc_sing.cuf"
nvfortran -o gc_sing gc_sing.cuf || { echo "gc_sing 컴파일 실패"; exit 1; }

# 2. 현재 디렉토리에서 gc_sing 실행
echo "[2/4] 실행 중: ./gc_sing"
./gc_sing || { echo "gc_sing 실행 실패"; exit 1; }

# 3. 하위 폴더 ./single_edit 에서 single_lorentz.cuf 컴파일
echo "[3/4] 컴파일 중: ./single_edit/single_lorentz.cuf"
cd ./single_edit || { echo "single_edit 디렉토리 없음"; exit 1; }
nvfortran -o single single_lorentz.cuf || { echo "single 컴파일 실패"; exit 1; }

# 4. ./single_edit 에서 single 실행
echo "[4/4] 실행 중: ./single"
./single || { echo "single 실행 실패"; exit 1; }

echo "모든 작업 완료!"
