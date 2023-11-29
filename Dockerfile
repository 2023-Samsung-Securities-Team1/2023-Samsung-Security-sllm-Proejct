FROM ubuntu:20.04

# Install necessary tools including curl
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common curl

# Add NVIDIA's package repository
RUN curl -s -L https://nvidia.github.io/libnvidia-container/stable/ubuntu20.04/amd64/ | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
    wget -qO - https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
    apt-get update

# Install the NVIDIA Container Toolkit
RUN apt-get install -y nvidia-container-toolkit

# Set environment variables for CUDA
ENV CUDA_VERSION 11.1
ENV CUDNN_VERSION 8
ENV PATH /usr/local/cuda-11.1/bin${PATH:+:${PATH}}

# Setup work directory
WORKDIR /app

# Copy Jupyter notebooks and other necessary files from host to container
# Make sure these files exist on your host system
COPY *.ipynb .
COPY ./spdfs2 .

# Install and configure Jupyter Notebook
RUN pip3 install notebook
RUN jupyter notebook --generate-config --allow-root && \
    python3 -c "from jupyter_server.auth import passwd; print(passwd('samsung'))" > /tmp/passwd.txt && \
    HASHED_PASSWORD=$(cat /tmp/passwd.txt) && \
    sed -i "s|#c.ServerApp.password = .*|c.ServerApp.password = u'$HASHED_PASSWORD'|" /root/.jupyter/jupyter_notebook_config.py

# Expose the port Jupyter Notebook is running on
EXPOSE 8888

# Start Jupyter Notebook
ENTRYPOINT ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
