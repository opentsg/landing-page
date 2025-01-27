#!/usr/bin/env bash
# clog>  build
# short> build & inject metadata into clog
# extra> push main executables into tmp/
#                             _                       _                    _   _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___  | |  __ _   _ _    __| | (_)  _ _    __ _
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | | / _` | | ' \  / _` | | | | ' \  / _` |
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_| \__,_| |_||_| \__,_| |_| |_||_| \__, |
#        |_|                            |___/                                            |___/
# ------------------------------------------------------------------------------
# load build config and script helpers
[ -f clogrc/_cfg.sh   ] && source clogrc/_cfg.sh         # configure project
eval "$(clog Inc)"                                       # include clog helpers (sh, zsh & bash)
helper="$(dirname $0)/go-helper.sh" && source "$helper"  # build helpers

fInfo "Building Project$cS $bPROJECT $cT using $helper"

clog Check
[ $? -gt 0 ] && exit 1
# ------------------------------------------------------------------------------

# ensure tmp dir exists
mkdir -p tmp

branch="$(clog git branch)"
hash="$(clog git hash head)"                                            # use the head hash as the build hash
suffix="" && [[ "$branch" != "main" ]] && suffix="$branch"              # use the branch name as the suffix
app=opentsg-landing                                                     # command you type to run the build
title="OpenTSG Landing page"                                            # title of the software
linkerPath="github.com/opentsg/opentsg-landing/semver.SemVerInfo"       # go tool objdump -S tmp/opentsg-ctl-watchfolder-amd-lnx|grep /semver.SemVerInfo

if fShouldMake "build"; then
  fGoBuild tmp/$app-amd-lnx     linux   amd64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-amd-win.exe windows amd64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-amd-mac     darwin  amd64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-arm-lnx     linux   arm64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-arm-win.exe windows arm64 $hash "$suffix" $app "$title" "$linkerPath"
  fGoBuild tmp/$app-arm-mac     darwin  arm64 $hash "$suffix" $app "$title" "$linkerPath"
  
  fInfo "${cT}All built to the$cF tmp/$cT folder\n"
fi

if fShouldMake "ko"; then
  # config is in .ko.yaml
  # use the default docker repo unless told otherwise
  [ -z "$KO_DOCKER_REPO" ] && KO_DOCKER_REPO="$DOCKER_NS"
  ko build --base-import-paths --tags "0.1.0" --tags "latest" .
  
  fInfo "${cT}All built to the$cF tmp/$cT folder\n"
fi

