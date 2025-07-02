#!/bin/bash

# 빌드용 디렉토리 (모듈 .mod 파일 저장)
MODDIR=build

# 출력 파일 이름
OUTFILE=main.exe

# 소스 파일 목록
SRC=(
  deriv.cuf
  field_read/eqdsk_reader.cuf
  field_read/field_cal.cuf
  2var_interp.cuf
  rk4.cuf
  cyl_field_tracer.cuf
)

# build 디렉토리 없으면 생성
mkdir -p "$MODDIR"

# 컴파일
nvfortran -module "$MODDIR" -I "$MODDIR" "${SRC[@]}" -o "$OUTFILE"


# #######
# use rk4    ->       use deriv
#   use eqdsk_reader
#   use field_cal   ->   cudafor
#   use interp
#   use deriv 