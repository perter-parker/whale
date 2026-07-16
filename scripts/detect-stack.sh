#!/usr/bin/env bash
# whale detect-stack — lockfile/manifest 로 스택을 판별해 lint/test/typecheck/build 명령을 방출.
# 하드코딩 금지의 단일 지점. 출력: KEY=VALUE 라인 (파싱용).
#   PM / LINT / TEST / TYPECHECK / BUILD  (모르면 빈 값)
# package.json 이 있으면 scripts 에 실제 존재하는 것만 명령으로 채택한다.
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "PM="; exit 0; }

has_script() { # $1=script name; package.json scripts 에 존재하는가
  [ -f package.json ] || return 1
  if command -v jq >/dev/null 2>&1; then
    jq -e --arg s "$1" '.scripts[$s] // empty' package.json >/dev/null 2>&1
  else
    grep -Eq "\"$1\"[[:space:]]*:" package.json
  fi
}

PM=""; LINT=""; TEST=""; TYPECHECK=""; BUILD=""

if [ -f pnpm-lock.yaml ]; then PM="pnpm"; run="pnpm"
elif [ -f yarn.lock ]; then PM="yarn"; run="yarn"
elif [ -f package-lock.json ] || [ -f package.json ]; then PM="npm"; run="npm run"
fi

if [ -n "$PM" ]; then
  has_script lint      && LINT="$run lint"
  has_script test      && TEST="$run test"
  has_script typecheck && TYPECHECK="$run typecheck"
  # typecheck 스크립트 없으면 tsc 폴백
  [ -z "$TYPECHECK" ] && [ -f tsconfig.json ] && TYPECHECK="npx tsc --noEmit"
  has_script build     && BUILD="$run build"
elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  PM="gradle"
  gw="./gradlew"; [ -x "$gw" ] || gw="gradle"
  LINT="$gw spotlessCheck"; TEST="$gw test"; BUILD="$gw build"
elif [ -f pom.xml ]; then
  PM="maven"
  LINT="mvn -q checkstyle:check"; TEST="mvn -q test"; BUILD="mvn -q package"
elif [ -f pyproject.toml ] || [ -f poetry.lock ]; then
  PM="python"
  command -v ruff >/dev/null 2>&1 && LINT="ruff check ."
  TEST="pytest -q"
elif [ -f requirements.txt ]; then
  PM="python"
  command -v ruff >/dev/null 2>&1 && LINT="ruff check ."
  TEST="pytest -q"
fi

echo "PM=$PM"
echo "LINT=$LINT"
echo "TEST=$TEST"
echo "TYPECHECK=$TYPECHECK"
echo "BUILD=$BUILD"
