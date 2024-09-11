# 第一阶段：用于编译 dlib
FROM debian:bookworm-slim AS build

# 设置非交互模式，防止某些软件包要求用户输入
ENV DEBIAN_FRONTEND=noninteractive

# 使用清华大学镜像源
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free" >> /etc/apt/sources.list && \
    apt-get clean && apt-get update

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev \
    git \
    wget \
    curl \
    ca-certificates \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 克隆 dlib 并编译安装
RUN git clone --depth=1 https://github.com/davisking/dlib.git /dlib \
    && cd /dlib \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . --config Release \
    && make install \
    && ldconfig \
    && rm -rf /dlib  # 清理构建文件

# 下载并编译 OpenCV，并确保包含 Aruco 模块
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.10.0.zip \
    && unzip opencv.zip \
    && cd opencv-4.10.0 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DOPENCV_ENABLE_NONFREE=ON \
             -DBUILD_opencv_aruco=ON \
             -DOPENCV_GENERATE_PKGCONFIG=ON  .. \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# 删除不需要的编译工具和清理系统，但保留 OpenCV 开发文件
RUN apt-get remove -y build-essential cmake git wget curl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*

# 创建 /models 目录
RUN mkdir -p /models

# 将本地的模型文件复制到镜像中（如有需要）
# COPY models/dlib_face_recognition_resnet_model_v1.dat /models/
# COPY models/mmod_human_face_detector.dat /models/
# COPY models/shape_predictor_5_face_landmarks.dat /models/

# 默认命令
CMD ["bash"]
