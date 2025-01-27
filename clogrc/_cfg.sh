#                             _                       _                    _   _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___  | |  __ _   _ _    __| | (_)  _ _    __ _
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | | / _` | | ' \  / _` | | | | ' \  / _` |
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_| \__,_| |_||_| \__,_| |_| |_||_| \__, |
#        |_|                            |___/                                            |___/
# Create params to control the build
eval "$(clog Inc)"

export PROJECT="$(basename $(pwd))"
export vCODE=$(clog git vcode)
export vCodeType="Golang"
export BASE="opentsg"
#define the things to build
export MAKE_ALL="build ko"
export MAKE="$MAKE_ALL"
