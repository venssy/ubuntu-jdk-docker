# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置环境变量，避免安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai

# 更新源并安装 OpenJDK 8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# 设置 Java 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# 验证安装
RUN java -version

# 设置工作目录
WORKDIR /app

