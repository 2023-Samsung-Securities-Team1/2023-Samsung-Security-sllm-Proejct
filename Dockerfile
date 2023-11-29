FROM ubuntu:20.04

# Install dependencies for adding NVIDIA repository
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common

# Add NVIDIA CUDA Toolkit repository
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget http://developer.download.nvidia.com/compute/cuda/11.1.1/local_installers/cuda-repo-ubuntu2004-11-1-local_11.1.1-455.32.00-1_amd64.deb && \
    dpkg -i cuda-repo-ubuntu2004-11-1-local_11.1.1-455.32.00-1_amd64.deb && \
    apt-key add /var/cuda-repo-ubuntu2004-11-1-local/7fa2af80.pub && \
    apt-get update

# Add NVIDIA cuDNN repository
# Note: Adjust the machine learning repository and cuDNN package name based on the available version
RUN wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/nvidia-machine-learning-repo-ubuntu2004_1.0.0-1_amd64.deb && \
    dpkg -i nvidia-machine-learning-repo-ubuntu2004_1.0.0-1_amd64.deb && \
    apt-get update

# Install CUDA Toolkit and cuDNN library
RUN apt-get install -y --no-install-recommends \
    cuda-toolkit-11-1 \
    libcudnn8

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
