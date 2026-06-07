# prac 1

FROM ubuntu:24.04

WORKDIR /project

CMD ["/bin/bash"]

# docker build -t prac1-ubuntu:24.04 .

# docker run -it prac1-ubuntu:24.04

# prac 2
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY message.txt /data/

CMD ["/bin/bash/data"]