#!/usr/bin/env bash

if [[ -n "$(docker ps -qaf 'name=spotify')" ]]; then
  docker restart spotify
else
  USER_UID=$(id -u)
  USER_GID=$(id -g)
  xhost "si:localuser:${USER}"

  docker run --name spotify \
    -e "DISPLAY=unix${DISPLAY}" \
    -v /etc/localtime:/etc/localtime:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v "${HOME}/.spotify/config:/data/config" \
    -v "${HOME}/.spotify/cache:/data/cache" \
    --device /dev/snd \
    jess/spotify
fi

