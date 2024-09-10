# 使用 Debian Bookworm 作为基础镜像
FROM debian:bookworm

# 设置非交互模式，防止某些软件包要求用户输入
ENV DEBIAN_FRONTEND=noninteractive

# 创建 /etc/apt/sources.list 文件并写入阿里云的源地址
#RUN echo "deb http://mirrors.aliyun.com/debian/ bookworm main contrib non-free" > /etc/apt/sources.list \
#    && echo "deb-src http://mirrors.aliyun.com/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb http://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb-src http://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb http://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb-src http://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb http://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free" >> /etc/apt/sources.list \
#    && echo "deb-src http://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free" >> /etc/apt/sources.list


# 更新包列表，安装依赖库，编译和安装 dlib 和 OpenCV，之后删除不必要的工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && git clone --depth=1 https://github.com/davisking/dlib.git /dlib \
    && cd /dlib \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . --config Release \
    && make install \
    && ldconfig \
    && cd / && rm -rf /dlib \
    && apt-get remove -y build-essential cmake git wget curl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建 /models 目录
RUN mkdir -p /models

# 将本地的模型文件复制到镜像中（如有需要）
# COPY models/dlib_face_recognition_resnet_model_v1.dat /models/
# COPY models/mmod_human_face_detector.dat /models/
# COPY models/shape_predictor_5_face_landmarks.dat /models/

# 默认命令
CMD ["bash"]