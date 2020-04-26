FROM knipegp/docker-base:0.0.1

USER root
WORKDIR /root

Run apt-get update && apt-get install -y \
    # Riscv-gnu-toolchain
    autoconf \
    automake \
    autotools-dev \
    curl \
    python3 \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat-dev \
    git \
    # Qemu
    pkg-config \
    glibc-source \
    libglib2.0-dev \
    libfdt-dev \
    libpixman-1-dev \
    zlib1g-dev

RUN cd / \
    && git clone --jobs=8 --recursive https://github.com/riscv/riscv-gnu-toolchain \
    && cd riscv-gnu-toolchain \
    && ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32 \
    && make -j8 \
    && cd / \
    && rm -rf riscv-gnu-toolchain

RUN cd / \
    && git clone https://git.qemu.org/git/qemu.git \
    && cd qemu \
    && ./configure --target-list=riscv32-softmmu \
    && make -j8 install \
    && cd / \
    && rm -rf qemu

# RUN ln -s /opt/riscv/sysroot/lib/ld-linux-riscv32-ilp32.so.1 /lib/ld-linux-riscv32-ilp32.so.1

RUN apt-get install -y device-tree-compiler openocd
RUN git clone https://github.com/riscv/riscv-isa-sim.git
RUN cd riscv-isa-sim \
    && mkdir build \
    && cd build \
    && ../configure --prefix=/opt/riscv \
    && make install

USER developer
WORKDIR /home/developer

ENV LD_LIBRARY_PATH=/opt/riscv/sysroot/lib
ENV PATH="/opt/riscv/bin:${PATH}"
