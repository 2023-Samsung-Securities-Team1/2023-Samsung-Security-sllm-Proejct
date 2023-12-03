FROM ubuntu:20.04

# Update the package list and install python3-pip and git
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git

WORKDIR /app

# Copy Jupyter notebooks and other necessary files from host to container
COPY *.ipynb .
COPY ./spdfs2 .

# Install Jupyter Notebook
RUN pip3 install notebook

# Expose the port Jupyter Notebook is running on
EXPOSE 8888

# Start Jupyter Notebook
ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
