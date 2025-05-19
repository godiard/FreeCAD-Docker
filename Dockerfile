FROM ubuntu:jammy

ENV FREECAD_VERSION="FreeCAD-1-0"

LABEL MAINTAINER="xxxx@example.com"
LABEL DESCRIPTION="A docker image to build FreeCAD locally"
LABEL VERSION="$FREECAD_VERSION"

SHELL ["/bin/bash", "-c"]

WORKDIR /tmp

# REF: https://wiki.freecad.org/Compile_on_Linux

# #!/bin/sh
# sudo add-apt-repository --enable-source ppa:freecad-maintainers/freecad-daily && sudo apt-get update
# sudo apt-get build-dep freecad-daily
# sudo apt-get install freecad-daily

# git clone --recurse-submodules https://github.com/FreeCAD/FreeCAD.git freecad-source
# mkdir freecad-build
# cd freecad-build
# cmake -DPYTHON_EXECUTABLE=/usr/bin/python3 -DFREECAD_USE_PYBIND11=ON ../freecad-source
# make -j$(nproc --ignore=2)

ENV DEBIAN_FRONTEND=noninteractive

# Build tools, and misc supporting tools
RUN apt update && \
    apt install -y build-essential cmake libtool lsb-release git

# Python3
RUN apt install -y python3 swig

# Boost libraries
RUN apt install -y \
    libboost-dev \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-iostreams-dev \
    libboost-program-options-dev \
    libboost-python-dev \
    libboost-regex-dev \
    libboost-serialization-dev \
    libboost-thread-dev

# Coin libraries
RUN apt install -y libcoin-dev libcoin-doc libcoin-runtime

# Misc libraries
RUN apt install -y \
    libeigen3-dev \
    libgts-bin \
    libgts-dev \
    libkdtree++-dev \
    libmedc-dev \
    libopencv-dev \
    libproj-dev \
    libvtk9-dev \
    libx11-dev \
    libxerces-c-dev \
    libyaml-cpp-dev \
    libzipios++-dev

# Python 3 and Qt6
#RUN apt install -y \
#    libpyside2-dev \
#    libqt6opengl6-dev \
#    libqt6svg6-dev \
#    libqt6x11extras6-dev \
#    libqt6xmlpatterns6-dev \
#    libshiboken2-dev \
#    pyqt6-dev-tools \
#    pyside2-tools \
#    python3-dev \
#    python3-matplotlib \
#    python3-packaging \
#    python3-pivy python3-pybind11 \
#    python3-ply \
#    python3-pyside2.qtcore \
#    python3-pyside2.qtgui \
#    python3-pyside2.qtnetwork \
#    python3-pyside2.qtsvg \
#    python3-pyside2.qtwebchannel \
#    python3-pyside2.qtwebengine \
#    python3-pyside2.qtwebenginecore \
#    python3-pyside2.qtwebenginewidgets \
#    python3-pyside2.qtwidgets \
#    qtbase6-dev \
#    qt6-tools-dev \
#    qt6-webengine-dev



RUN apt install -y libqt6opengl6-dev libqt6svg6-dev libshiboken2-dev \
    qt6-base-dev qt6-tools-dev \
    python3-dev python3-matplotlib python3-packaging python3-pivy \
    python3-pybind11 python3-ply \
    qt6-webengine-dev qt6-l10n-tools qt6-tools-dev-tools

# OpenCascade
RUN apt install -y libocct*-dev occt-draw

# Optional packges
RUN apt install -y \
    checkinstall \
    doxygen \
    graphviz \
    libsimage-dev \
    libspnav-dev

# To fix compilation problems
RUN apt install -y \
    libhdf5-openmpi-dev \
    python3-pip

# Known python dependencies
RUN python3 -m pip install ifcopenshell==0.8.0

WORKDIR /root
RUN python3 -m pip install pyside6
# build pyside, based on instrctions from https://pypi.org/project/PySide6/
#RUN git clone https://code.qt.io/pyside/pyside-setup && \
#    cd pyside-setup && \
#    # if a specific version is needed
#    git checkout 6.9 &&\
#    python3 setup.py install --qtpaths=/usr/local/bin --build-tests

# DEBUG C++ with gdb
RUN apt install -y gdb libcanberra-gtk-module libcanberra-gtk3-module
RUN python3 -m pip install gdbgui
ENV FREECAD_GDB_PORT=5000
EXPOSE 5000

# DEBUG Python with winpdb
RUN apt install -y wxpython-tools
RUN python3 -m pip install winpdb-reborn
ENV FREECAD_WINPDB_PORT=51000
ENV FREECAD_WINPDB_PWD=1234
EXPOSE 51000

# These environment variable are set here to be used
#   by the different container's scripts
ENV FREECAD_CONFIG_DIR="/root/.local/FreeCAD"
ENV FREECAD_BUILD_DIR="/mnt/build"
ENV FREECAD_SOURCE_DIR="/mnt/source"

# Add the build & debug scripts
ADD add_files/build_FC.sh /root/build_FC.sh
ADD add_files/debug_FC_cpp.sh /root/debug_FC_cpp.sh
ADD add_files/debug_FC_python.sh /root/debug_FC_python.sh
ADD add_files/debug_FC_init.py /root/debug_FC_init.py

WORKDIR /root

# Note for later: May need -fPIC
