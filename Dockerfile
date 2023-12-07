FROM ubuntu:20.04

# Update the package list and install python3-pip and git
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git

WORKDIR /app

COPY . .

# Install Jupyter Notebook
RUN pip3 install notebook

# Expose the port Jupyter Notebook is running on
EXPOSE 8888

# Start Jupyter Notebook
ENTRYPOINT ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888"]
