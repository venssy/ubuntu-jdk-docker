# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置环境变量，避免安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

RUN timedatectl set-timezone Asia/Shanghai

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
















FROM alpine:edge AS builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk upgrade && apk add go git
    
WORKDIR /data

# RUN go env -w GOPROXY=https://gh-proxy.com,direct
RUN git clone https://gh-proxy.com/https://github.com/caddyserver/xcaddy.git --depth 1 
WORKDIR /data/xcaddy/cmd/xcaddy

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=cache,target=/root/.cache/go-build/ \
    go run main.go build latest \
    --with github.com/greenpau/caddy-security \
    --with github.com/caddy-dns/tencentcloud \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/mholt/caddy-webdav \
    --with github.com/lucaslorentz/caddy-docker-proxy/v2 \
    --with github.com/caddy-dns/alidns \
    --with github.com/abiosoft/caddy-exec

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=cache,target=/root/.cache/go-build/ \
    /data/xcaddy/cmd/xcaddy/caddy -v

FROM alpine:edge

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache tzdata ca-certificates python3 py3-pip docker bash && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

COPY --from=builder /data/xcaddy/cmd/xcaddy/caddy /usr/bin/

WORKDIR /data

ENV TZ=Asia/Shanghai \
    DNS=""
    
ENV XDG_DATA_HOME="/data"
ENV XDG_CONFIG_HOME="/config"

CMD ["caddy", "docker-proxy"]
# CMD [ "caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile" ]
