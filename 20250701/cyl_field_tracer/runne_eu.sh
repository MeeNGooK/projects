#!/bin/bash

# 빌드용 디렉토리 (모듈 .mod 파일 저장)
MODDIR=build2

# 출력 파일 이름
OUTFILE=main2.exe

# 소스 파일 목록
SRC=(
  deriv.cuf
  field_read/eqdsk_reader.cuf
  field_read/field_cal.cuf
  2var_interp.cuf
  cyl_field_euler.cuf
)

# build 디렉토리 없으면 생성
mkdir -p "$MODDIR"

# 컴파일
echo ">>> Compiling..."
nvfortran -module "$MODDIR" -I "$MODDIR" "${SRC[@]}" -o "$OUTFILE"
compile_status=$?

# 컴파일 성공 여부 확인
if [ $compile_status -eq 0 ]; then
  echo ">>> Compilation successful. Running $OUTFILE..."
  ./"$OUTFILE"
else
  echo ">>> Compilation failed. $OUTFILE will not run."
fi
