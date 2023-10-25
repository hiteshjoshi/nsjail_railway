FROM debian:bookworm-slim as nsjail

WORKDIR /nsjail


RUN  apt-get -y update \
    && apt-get install -y \
    bison=2:3.8.* \
    flex=2.6.* \
    g++=4:12.2.* \
    gcc=4:12.2.* \
    git=1:2.39.* \
    libprotobuf-dev=3.21.* \
    libnl-route-3-dev=3.7.* \
    make=4.3-4.1 \
    pkg-config=1.8.* \
    protobuf-compiler=3.21.*


RUN git clone -b master --single-branch https://github.com/google/nsjail.git . \
    && git checkout dccf911fd2659e7b08ce9507c25b2b38ec2c5800
RUN make

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
       ca-certificates \
       pkg-config \
       libssl-dev \
       libprotobuf-dev=3.21.* \
        libnl-route-3-dev \
       libpq5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ADD bun.proto .
ADD index.ts .


COPY --from=oven/bun:1.0.6 /usr/local/bin/bun /usr/bin/bun
COPY --from=nsjail /nsjail/nsjail /bin/nsjail

RUN mkdir .bun

CMD ["/bin/nsjail", "--config", "bun.proto", "--", "/usr/bin/bun", "run", "index.ts"]
