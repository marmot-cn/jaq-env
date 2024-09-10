# 第一阶段：用于编译 dlib
FROM debian:bookworm-slim AS build

# 设置非交互模式，防止某些软件包要求用户输入
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装编译 dlib 所需的依赖
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 克隆 dlib 并编译安装
RUN git clone --depth=1 https://github.com/davisking/dlib.git /dlib \
    && cd /dlib \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . --config Release \
    && make install \
    && ldconfig

# 第二阶段：用于生产环境的精简镜像
FROM debian:bookworm-slim

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 安装运行时依赖（如 OpenCV 库）
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libopencv-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制 dlib 安装的文件
COPY --from=build /usr/local /usr/local

# 创建 /models 目录
RUN mkdir -p /models

# 将本地的模型文件复制到镜像中（如有需要）
# COPY models/dlib_face_recognition_resnet_model_v1.dat /models/
# COPY models/mmod_human_face_detector.dat /models/
# COPY models/shape_predictor_5_face_landmarks.dat /models/

# 默认命令
CMD ["bash"]
