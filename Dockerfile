ARG BASE_IMAGE

FROM debian:12-slim as base-model-downloader
RUN apt update && apt install aria2 -y
FROM ${BASE_IMAGE} as final

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

ARG WORKDIR
WORKDIR ${WORKDIR}

RUN apt update -y && apt install git wget ffmpeg -y

ARG COMFYUI_SHA
RUN git clone https://github.com/comfyanonymous/ComfyUI

WORKDIR ${WORKDIR}/ComfyUI

RUN git checkout ${COMFYUI_SHA}

ARG PYTORCH_VERSION
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch==${PYTORCH_VERSION} jupyterlab && \
    pip install -r requirements.txt

RUN pip3 install runpod requests

# RUN git -C ./custom_nodes clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git && \
#     git -C ./custom_nodes clone --depth 1 https://github.com/mav-rik/facerestore_cf.git && \
#     git -C ./custom_nodes clone --depth 1 https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive
    
COPY src/* .
# RUN chmod +x ./install-nodes-dependencies.sh
# RUN --mount=type=cache,target=/root/.cache/pip \
#     ./install-nodes-dependencies.sh


RUN chmod +x ./setup-ssh.sh
# RUN chmod +x ./start.sh

RUN ./setup-ssh.sh

CMD ["/workspace/ComfyUI/start.sh"]