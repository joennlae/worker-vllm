ARG WORKER_CUDA_VERSION=11.8.0
FROM runpod/worker-vllm:base-0.3.2-cuda${WORKER_CUDA_VERSION} AS vllm-base

RUN apt-get update -y \
    && apt-get install -y python3-pip git

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt

# Setup for Option 2: Building the Image with the Model included
ARG MODEL_NAME=""
ARG TOKENIZER_NAME=""
ARG BASE_PATH="/runpod-volume"
ARG QUANTIZATION=""
ARG MODEL_REVISION=""
ARG TOKENIZER_REVISION=""

ENV MODEL_NAME=$MODEL_NAME \
    MODEL_REVISION=$MODEL_REVISION \
    TOKENIZER_NAME=$TOKENIZER_NAME \
    TOKENIZER_REVISION=$TOKENIZER_REVISION \
    BASE_PATH=$BASE_PATH \
    QUANTIZATION=$QUANTIZATION \
    HF_DATASETS_CACHE="${BASE_PATH}/huggingface-cache/datasets" \
    HUGGINGFACE_HUB_CACHE="${BASE_PATH}/huggingface-cache/hub" \
    HF_HOME="${BASE_PATH}/huggingface-cache/hub" \
    HF_TRANSFER=1 

ENV PYTHONPATH="/:/vllm-installation"

# Download the model to models
#  HF_HOME=/scratch/models MODEL_NAME=TheBloke/Nous-Hermes-2-Mixtral-8x7B-DPO-GPTQ MODEL_REVISION=gptq-8bit-128g-actorder_True python download_model.py
COPY ./models $HF_HOME
# RUN \
#   echo "$HF_HOME/models--TheBloke--Nous-Hermes-2-Mixtral-8x7B-DPO-GPTQ/snapshots/6538043ab1bb83d59ebc8584f3a863626038e917" > /local_model_path.txt && \
#   echo "$HF_HOME/models--TheBloke--Nous-Hermes-2-Mixtral-8x7B-DPO-GPTQ/snapshots/3bad824e55ebf468b1313560eca97504fa8d0e89" > /local_tokenizer_path.txt

# Add source files
COPY src /src


# Start the handler
CMD ["python3", "/src/handler.py"]
