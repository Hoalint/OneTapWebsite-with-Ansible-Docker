# docker build -t onetap-website:latest .
# 使用php:8.1-apache作为基础镜像（Apache + PHP）
FROM php:8.1-apache

# 设置维护者标签
LABEL maintainer="OneTapWebsite Maintainers"

# 设置工作目录
WORKDIR /var/www/html

# 启用Apache重写模块（php:8.1-apache 镜像可能已经启用，但确保一下）
RUN a2enmod rewrite 
# 需要php-mysqlnd才能读取mariadb-server中的数据
RUN apt-get update && apt-get install -y \
    # 安装mysqlnd/pdo_mysql扩展所需的系统库
    libpq-dev \
    libpng-dev \
    libzip-dev \
    zip \
    # 安装MariaDB客户端库（可选，用于mysql命令行测试）
    mariadb-client \
    && docker-php-ext-install -j$(nproc) \
    # 安装必需的PHP扩展
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置文件权限，确保Apache用户可以读写
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 复制环境变量和配置文件（如果不存在则创建默认）
COPY .env /var/www/html/.env
COPY ./apache-config.conf /etc/apache2/conf-enabled/docker-php.conf

# 复制项目文件到容器中
COPY . /var/www/html/

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 使用Apache作为前台进程运行
CMD ["apache2-foreground"]
