FROM ubuntu:20.04

# Update the package list and install packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip git curl net-tools wget gnupg2 software-properties-common linux-headers-$(uname -r)

# Add NVIDIA package repositories
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add - && \
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list && \
    apt-key del 7fa2af80 && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda-ubuntu2004-x86_64.list && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Install NVIDIA Container Toolkit and CUDA
RUN apt-get update && \
    apt-get install -y nvidia-container-toolkit cuda-11-6 cuda-cudart-11-6 cuda-cudart-dev-11-6 && \
    ln -s /usr/local/cuda-11-6 /usr/local/cuda

# Set environment variables
ENV CUDA_VERSION 11.6
ENV CUDNN_VERSION 8
ENV PATH /usr/local/cuda/bin:${PATH}

WORKDIR /app

# Copy Jupyter notebooks and other necessary files from host to container
COPY *.ipynb .
COPY ./spdfs2 .

# Install Jupyter Notebook
RUN pip3 install notebook

# Configure Jupyter Notebook
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.password = u'$(echo samsung | python3 -c "from notebook.auth import passwd; print(passwd())")'" >> /root/.jupyter/jupyter_notebook_config.py

# Expose the port Jupyter Notebook is running on
EXPOSE 8888

# Start Jupyter Notebook
ENTRYPOINT ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
