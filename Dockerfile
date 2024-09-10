# 使用 Debian Bookworm 作为基础镜像
FROM debian:bookworm

# 设置非交互模式，防止某些软件包要求用户输入
ENV DEBIAN_FRONTEND=noninteractive

# 将所有安装和清理命令合并到一个 RUN 中，以减少层的数量
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
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
    libopencv-dev \
    && git clone --depth=1 https://github.com/davisking/dlib.git /dlib \
    && cd /dlib && mkdir build && cd build \
    && cmake .. && cmake --build . --config Release \
    && make install && ldconfig \
    && apt-get remove -y build-essential cmake git wget curl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /dlib /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建 /models 目录
RUN mkdir -p /models

# 将本地的模型文件复制到镜像中（如有需要）
# COPY models/dlib_face_recognition_resnet_model_v1.dat /models/
# COPY models/mmod_human_face_detector.dat /models/
# COPY models/shape_predictor_5_face_landmarks.dat /models/

# 默认命令
CMD ["bash"]