# 기반 이미지 설정
FROM ubuntu:20.04

# 필요한 패키지 설치
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

COPY *.ipynb .

# 주피터 노트북 설치
RUN pip3 install notebook

RUN jupyter notebook --generate-config --allow-root

RUN echo "c.NotebookApp.password = 'samsung'" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

ENTRYPOINT jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 --no-browser

