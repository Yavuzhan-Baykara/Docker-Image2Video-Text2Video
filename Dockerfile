ARG BASE_IMAGE

FROM debian:12-slim as base-model-downloader
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

RUN apt update && apt install aria2 -y
FROM ${BASE_IMAGE} as final

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all


RUN pip install comfy-cli
RUN /usr/bin/yes | comfy --workspace /ComfyUI install --cuda-version 11.8 --nvidia --version 0.2.7

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

COPY src/* .

RUN chmod +x ./setup-ssh.sh

RUN ./setup-ssh.sh

EXPOSE 8188 8888

CMD ["/workspace/ComfyUI/start.sh"]
