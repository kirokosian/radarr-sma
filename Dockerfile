FROM ghcr.io/linuxserver/radarr
LABEL maintainer="kirokosian <kirokosian@pm.me>"

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Radarr
ENV SMA_UPDATE false
ENV SMA_FFMPEG_PATH ffmpeg
ENV SMA_FFPROBE_PATH ffprobe

# get python3 and git, and install python libraries
RUN \
  apk update && \
  apk add --no-cache \
    git \
    wget \
    python3 \
    py3-pip \
    py3-virtualenv \
    ffmpeg \
    mesa-va-gallium \
    libva-utils && \
  # use the VAAPI-capable Alpine ffmpeg (h264_vaapi/hevc_vaapi) for HW transcoding
  ln -sf /usr/bin/ffmpeg  /usr/local/bin/ffmpeg && \
  ln -sf /usr/bin/ffprobe /usr/local/bin/ffprobe && \
# make directory
  mkdir ${SMA_PATH} && \
# download repo
  git config --global --add safe.directory ${SMA_PATH} && \
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m virtualenv ${SMA_PATH}/venv && \
  ${SMA_PATH}/venv/bin/pip install -r ${SMA_PATH}/setup/requirements.txt && \
# cleanup
  rm -rf \
    /root/.cache \
    /tmp/*

EXPOSE 7878

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
