FROM ubuntu:20.04

# 필요한 패키지 설치
# ... previous steps ...

# Update the package list and install python3-pip and git
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl
    
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list

# Update package lists and install NVIDIA Container Toolkit
RUN apt-get update && \
    apt-get install -y nvidia-container-toolkit
    
# Install necessary tools and kernel headers
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common linux-headers-$(uname -r)

# Remove outdated signing key, if necessary
RUN apt-key del 7fa2af80

# Download and install the CUDA keyring
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb

# Add the CUDA repository
RUN echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda-ubuntu2004-x86_64.list

# Add pin file to prioritize CUDA repository
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Update package lists and install CUDA
RUN apt-get update && \
    apt-get install -y cuda


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
