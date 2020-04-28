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
    # OpenOCD
    pkg-config \
    libtool \
    # Spike
    device-tree-compiler

RUN cd / \
    && git clone --jobs=8 --recursive https://github.com/riscv/riscv-gnu-toolchain \
    && cd riscv-gnu-toolchain \
    && ./configure --prefix=/opt/riscv --enable-multilib \
    && make -j8 \
    && make -j8 linux \
    && cd / \
    && rm -rf riscv-gnu-toolchain

# RUN ln -s /opt/riscv/sysroot/lib/ld-linux-riscv32-ilp32.so.1 /lib/ld-linux-riscv32-ilp32.so.1

RUN cd / \
    && git clone https://github.com/riscv/riscv-isa-sim.git \
    && cd riscv-isa-sim \
    && mkdir build \
    && cd build \
    && ../configure --prefix=/opt/riscv \
    && make -j8 install \
    && cd / \
    && rm -rf riscv-isa-sim

RUN cd / \
    && git clone https://github.com/riscv/riscv-openocd.git \
    && cd riscv-openocd \
    && ./bootstrap \
    && ./configure -prefix=/opt/riscv --enable-remote-bitbang --enable-jtag_vpi --disable-werror \
    && make -j8 install \
    && cd / \
    && rm -rf riscv-openocd

USER developer
WORKDIR /home/developer

ENV LD_LIBRARY_PATH=/opt/riscv/sysroot/lib
ENV PATH="/opt/riscv/bin:${PATH}"
