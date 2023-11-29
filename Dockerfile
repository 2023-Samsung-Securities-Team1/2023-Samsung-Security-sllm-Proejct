FROM ubuntu:20.04

# NVIDIA CUDA Toolkit 및 cuDNN 저장소 추가 및 설치
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget http://developer.download.nvidia.com/compute/cuda/11.1.1/local_installers/cuda-repo-ubuntu2004-11-1-local_11.1.1-455.32.00-1_amd64.deb && \
    dpkg -i cuda-repo-ubuntu2004-11-1-local_11.1.1-455.32.00-1_amd64.deb && \
    apt-key add /var/cuda-repo-ubuntu2004-11-1-local/7fa2af80.pub && \
    apt-get update

# 필요한 시스템 패키지 설치
RUN apt-get install -y --no-install-recommends \
    build-essential \
    cuda-toolkit-11-1 \
    libcudnn8 \
    python3 \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm cuda-repo-ubuntu2004-11-1-local_11.1.1-455.32.00-1_amd64.deb

# Set the CUDA version to match the CUDA toolkit version installed
ENV CUDA_VERSION 11.1
ENV CUDNN_VERSION 8

# Set PATH for cuda 11.1 installation
ENV PATH /usr/local/cuda-11.1/bin${PATH:+:${PATH}}

# pip로 필요한 Python 패키지들 설치
# 필요에 따라 주석을 해제하고 사용하세요.
# RUN pip3 install peft Faiss-cpu langchain rank_bm25 sentence-transformers pypdf chromadb sentencepiece bitsandbytes
# RUN pip3 install -q -U git+https://github.com/huggingface/transformers.git
# RUN pip3 install -q -U git+https://github.com/huggingface/peft.git
# RUN pip3 install -q -U git+https://github.com/huggingface/accelerate.git
# RUN pip3 install -q datasets

# 작업 디렉토리 설정
WORKDIR /app

# Jupyter 노트북 파일 및 기타 파일 복사
COPY *.ipynb .
COPY ./spdfs2 .

# 주피터 노트북 설치 및 설정
RUN pip3 install notebook
RUN jupyter notebook --generate-config --allow-root && \
    python3 -c "from jupyter_server.auth import passwd; print(passwd('samsung'))" > /tmp/passwd.txt && \
    HASHED_PASSWORD=$(cat /tmp/passwd.txt) && \
    sed -i "s|#c.ServerApp.password = .*|c.ServerApp.password = u'$HASHED_PASSWORD'|" /root/.jupyter/jupyter_notebook_config.py

# 8888 포트 노출
EXPOSE 8888

# 주피터 노트북 실행
ENTRYPOINT ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
