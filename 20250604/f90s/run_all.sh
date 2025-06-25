#!/bin/bash

# 컴파일러 설정
FC=gfortran


echo "🔧 컴파일 중: gc_sing.f90 → gc_sing"
$FC gc_sing.f90 -o gc_sing 
if [ $? -ne 0 ]; then
  echo "❌ gc_sing 컴파일 실패"
  exit 1
fi

echo "🔧 컴파일 중: single_traj.f90 → single_traj"
$FC single_traj.f90 -o single_traj 
if [ $? -ne 0 ]; then
  echo "❌ single_traj 컴파일 실패"
  exit 1
fi

echo "🚀 실행 중: gc_sing"
./gc_sing
echo "✅ gc_sing 실행 완료 → gc_northrop_traj.dat"

echo "🚀 실행 중: single_traj"
./single_traj
echo "✅ single_traj 실행 완료 → single_traj.dat"
