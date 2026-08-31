# ugc-blender: headless Blender worker (x86_64). Pinned LTS tarball =
# reprodukovatelny build; zadny linuxserver GUI image.
FROM ubuntu:24.04

ARG BLENDER_VERSION=4.2.9
ARG BLENDER_SERIES=4.2

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils \
      libx11-6 libxi6 libxxf86vm1 libxfixes3 libxrender1 libgl1 libegl1 \
      libsm6 libice6 libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://download.blender.org/release/Blender${BLENDER_SERIES}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" \
      | tar -xJ -C /opt \
    && ln -s /opt/blender-${BLENDER_VERSION}-linux-x64/blender /usr/local/bin/blender

WORKDIR /app
COPY blender_scripts/ /app/blender_scripts/
COPY spec/ /app/spec/
COPY worker/worker.py /app/worker.py
COPY worker/fc_worker.py /app/fc_worker.py
COPY workflows/ /app/workflows/

# blender ma vlastni python; worker loop bezi v systemovem pythonu3
RUN apt-get update && apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/*

ENV UGC_API=http://ugc-api:8095 UGC_DATA=/data
CMD ["python3", "-u", "/app/worker.py"]
