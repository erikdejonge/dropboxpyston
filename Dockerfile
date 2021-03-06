FROM   erikdejonge/dropboxpystonbase
RUN     apt-get install -y apt-utils
RUN     apt-get install -y ccache
RUN     apt-get install -y libncurses5-dev zlib1g-dev liblzma-dev

RUN     apt-get install -y python-dev
RUN     apt-get install -y texlive-extra-utils autoconf
RUN     apt-get install -y zsh
RUN     apt-get install -y libreadline-dev
RUN     apt-get install -y libgmp3-dev
RUN     apt-get install -y bison
RUN     apt-get install -y linux-tools
RUN     apt-get install -y linux-tools
RUN     apt-get install -y distcc distcc-pump


WORKDIR /python_deps
RUN     git clone http://llvm.org/git/llvm.git llvm-trunk
RUN     git clone http://llvm.org/git/clang.git llvm-trunk/tools/clang
WORKDIR /pyston

RUN     make llvm_up
RUN     make llvm_configure
RUN     make llvm -j4

WORKDIR /python_deps

RUN     git clone git://git.sv.gnu.org/libunwind.git libunwind-trunk
RUN     mkdir libunwind-trunk-install
WORKDIR /python_deps/libunwind-trunk
RUN     git checkout 65ac867416
RUN     autoreconf -i

RUN     ./configure --prefix=$HOME/pyston_deps/libunwind-trunk-install --enable-shared=0
RUN     make -j4
RUN     make install

WORKDIR /python_deps
RUN     git clone git://github.com/vinzenz/pypa
RUN     mkdir pypa-install
WORKDIR /python_deps/pypa
RUN     ./autogen.sh
RUN     ./configure --prefix=$HOME/pyston_deps/pypa-install CXX=$HOME/pyston_deps/gcc-4.8.2-install/bin/g++
RUN     make -j4
RUN     make install

WORKDIR /python_deps
RUN     wget https://googletest.googlecode.com/files/gtest-1.7.0.zip
RUN     unzip gtest-1.7.0.zip
WORKDIR /python_deps/gtest-1.7.0
RUN     ./configure CXXFLAGS=-fno-omit-frame-pointer
RUN     make -j4


WORKDIR /python_deps
RUN     wget http://ftp.gnu.org/gnu/gdb/gdb-7.6.2.tar.gz
RUN     tar xf gdb-7.6.2.tar.gz
WORKDIR /python_deps/gdb-7.6.2
RUN     ./configure
RUN     make -j4
WORKDIR /pyston
RUN     echo "GDB := \$(DEPS_DIR)/gdb-7.6.2/gdb/gdb --data-directory \$(DEPS_DIR)/gdb-7.6.2/gdb/data-directory" >> Makefile.local

WORKDIR /python_deps

RUN     wget http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz
RUN     tar xf binutils-2.24.tar.gz
RUN     mkdir binutils-2.24-build
WORKDIR /python_deps/binutils-2.24-build
RUN     ../binutils-2.24/configure --enable-gold --enable-plugins --disable-werror
RUN     make all-gold -j4
