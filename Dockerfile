FROM ubuntu:20.04

# Install necessary packages and libraries for CUDA
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cuda-toolkit-11-1 \
    libcudnn8 \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the CUDA version to match the CUDA toolkit version installed
ENV CUDA_VERSION 11.1
ENV CUDNN_VERSION 8

# Set PATH for cuda 11.1 installation
ENV PATH /usr/local/cuda-11.1/bin${PATH:+:${PATH}}

# pip로 필요한 패키지들 설치
# RUN pip3 install peft
#RUN pip3 install Faiss-cpu
#RUN pip3 install langchain
#RUN pip3 install rank_bm25
#RUN pip3 install sentence-transformers
#RUN pip3 install pypdf
#RUN pip3 install chromadb
#RUN pip3 install sentencepiece
#RUN pip3 install -q -U bitsandbytes
#RUN pip3 install -q -U git+https://github.com/huggingface/transformers.git
#RUN pip3 install -q -U git+https://github.com/huggingface/peft.git
#RUN pip3 install -q -U git+https://github.com/huggingface/accelerate.git
#RUN pip3 install -q datasets

# 작업 디렉토리 설정
WORKDIR /app

# Jupyter 노트북 파일 복사
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
ENTRYPOINT jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 --no-browser
