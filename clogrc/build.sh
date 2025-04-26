# clog>  build # build & inject metadata into clog
# extra> push main executables into tmp/
#                             _                       _                    _   _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___  | |  __ _   _ _    __| | (_)  _ _    __ _
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | | / _` | | ' \  / _` | | | | ' \  / _` |
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_| \__,_| |_||_| \__,_| |_| |_||_| \__, |
#        |_|                            |___/                                            |___/
# ------------------------------------------------------------------------------
# load build config and script helpers
eval "$(clog Source project config)"
eval "$(clog Inc)"                                       # include clog helpers (sh, zsh & bash)
helper="core/sh/help-golang.sh"
eval "$(clog Cat $helper)"  # build helpers

clog Log -I  "Building Project$cS $bPROJECT $cT using clog $helper"

clog Check pre-build
[ $? -gt 0 ] && exit 1
# ------------------------------------------------------------------------------
EVERYTHING="build ko"
[ -n "$1" ] && MAKE="$1"

# ensure tmp dir exists
mkdir -p tmp

branch="$(clog git branch)"
hash="$(clog git hash head)"                                       # use the head hash as the build hash
suffix="" && [[ "$branch" != "main" ]] && suffix="$branch"         # use the branch name as the suffix
app=opentsg-app-home                                               # command you type to run the build
title="OpenTSG App Home"                                           # title of the software
linkerPath="github.com/opentsg/opentsg-app-home/semver.SemVerInfo" # go tool objdump -S tmp/opentsg-ctl-watchfolder-amd-lnx|grep /semver.SemVerInfo

if fShouldMake "build"; then
  fGoBuild tmp/$app-amd-lnx     linux   amd64 $hash "$suffix" $app "$title" "$linkerPath"
  # fGoBuild tmp/$app-amd-win.exe windows amd64 $hash "$suffix" $app "$title" "$linkerPath"
  # fGoBuild tmp/$app-amd-mac     darwin  amd64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-arm-lnx     linux   arm64 $hash "$suffix" $app "$title" "$linkerPath"
  # fGoBuild tmp/$app-arm-win.exe windows arm64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-arm-mac     darwin  arm64 $hash "$suffix" $app "$title" "$linkerPath"
  
  clog Log -I "${cT}All built to the$cF tmp/$cT folder\n"
fi

if fShouldMake "ko"; then
  # config is in .ko.yaml
  # use the default docker repo unless told otherwise
  [ -z "$DOCKER_NS" ] && DOCKER_NS="mrmxf"
  [ -z "$KO_DOCKER_REPO" ] && KO_DOCKER_REPO="$DOCKER_NS"
  ko build --base-import-paths --tags "$(clog git tag ref)" --tags "latest" .
  
  clog Log -I "${cT}All built to the$cF tmp/$cT folder\n"
  ls -al tmp/${app}*
  clog Log -I "multi-arch build$cF $PROJECT$cT:$cW$vCODE$cT and ${cW}latest"
fi

