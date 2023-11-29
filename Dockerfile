# 기반 이미지 설정
FROM ubuntu:20.04
 
# 필요한 패키지 설치
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    git && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
COPY 2023-Samsung-Security-sllm-Proejct/spdfs2 .

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
