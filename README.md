# OneTapWebsite with Ansible & Docker

[![Ansible](https://img.shields.io/badge/Ansible-2.14+-red.svg)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Supported OS](https://img.shields.io/badge/OS-CentOS%2FUbuntu%2FDebian-lightgrey.svg)](https://www.ansible.com/)

自动化部署一个基于LAMP栈的电子商务示例网站，实现跨Linux发行版的一键容器化部署。

## 🎯 项目概述

**OneTapWebsite with Ansible & Docker** 是一个展示现代DevOps实践的示例项目。它通过Ansible自动化工具，在远程Linux服务器上实现完整的Docker环境搭建、应用容器化部署和配置管理。

### ✨ 核心价值
- **一键部署**：单条命令完成从裸机到可访问网站的全流程部署
- **跨平台兼容**：支持CentOS、Ubuntu、Debian三大主流Linux发行版
- **生产就绪**：包含环境变量管理、防火墙配置、健康检查等生产环境最佳实践
- **问题驱动**：解决实际部署中遇到的SSH连接、模块兼容性、系统差异等典型问题

## 🛠 技术栈

| 组件 | 用途 | 版本 |
|------|------|------|
| **Ansible** | 自动化配置管理 | 2.14+ |
| **Docker** | 应用容器化 | 20.10+ |
| **Docker Compose** | 多容器编排 | v2+ |
| **Python** | Ansible运行环境 | 3.8+ |
| **Apache + PHP** | Web服务器 | LAMP栈 |
| **MariaDB** | 数据库 | 容器化运行 |

## 🚀 快速开始

### 前提条件
- **控制机**：运行Ansible的Linux/MacOS机器（需要Python 3.8+）
- **目标机**：CentOS 7+/Ubuntu 20.04+/Debian 11+ 服务器
- **网络**：控制机可通过SSH连接目标机
- **权限**：目标机上的root或sudo权限

### 5分钟部署演示
```bash
# 1. 克隆项目
git clone https://github.com/Hoalint/OneTapWebsite-with-Ansible-Docker.git
cd OneTapWebsite-with-Ansible-Docker

# 2. 配置目标主机（编辑inventory.ini）
# 将your_server_ip替换为您的服务器IP
echo "[webservers]" > inventory.ini
echo "target_host ansible_host=your_server_ip ansible_user=root" >> inventory.ini

# 3. 设置SSH密钥认证（如未配置）
ssh-keygen -t ed25519 -C "ansible@localhost"
ssh-copy-id root@your_server_ip

# 4. 激活Python虚拟环境并安装Ansible
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# Windows: .venv\Scripts\activate
pip install "ansible<10.0.0"

# 5. 一键部署
ansible-playbook -i inventory.ini playbook.yml
```

## 📖 详细指南

### 1. SSH密钥配置
SSH免密登录是自动化部署的基础：
```bash
# 生成ED25519密钥对（更安全）
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key -N ""

# 上传公钥到目标服务器
ssh-copy-id -i ~/.ssh/ansible_key.pub root@your_server_ip

# 测试连接
ssh -i ~/.ssh/ansible_key root@your_server_ip
```

### 2. Inventory文件配置
`inventory.ini` 文件定义目标主机：
```ini
[webservers]
# 基础格式：主机名 ansible_host=IP地址 ansible_user=用户名
target_host ansible_host=192.168.1.100 ansible_user=root

# 可选高级配置
# target_host ansible_host=45.76.251.59 ansible_user=root \
#   ansible_ssh_private_key_file=~/.ssh/ansible_key \
#   ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### 3. 环境变量管理
项目使用`.env`文件管理敏感信息：
```bash
# .env文件示例
DB_HOST=localhost
DB_USER=ecomuser
DB_PASSWORD=ecompassword
DB_NAME=ecomdb
```
Ansible会自动将此文件复制到目标服务器，确保配置安全。

## 📁 项目结构

```
OneTapWebsite-with-Ansible-Docker/
├── playbook.yml              # 主Ansible Playbook
├── inventory.ini             # 主机清单配置
├── docker-compose.yml        # Docker Compose配置
├── dockerfile               # 应用Docker镜像构建文件
├── .env                     # 环境变量模板
├── index.php               # PHP应用主文件
├── apache-config.conf      # Apache配置文件
├── assets/
│   └── db-load-script.sql  # 数据库初始化脚本
├── css/                    # 前端样式文件
├── js/                     # JavaScript文件
├── img/                    # 网站图片资源
├── vendors/                # 第三方前端库
└── README.md              # 本文件
```

## 💡 技术亮点

### 🔄 自动化全流程覆盖
- **环境准备**：自动检测操作系统类型，安装对应的Docker和依赖包
- **代码部署**：Git克隆项目代码，确保版本一致性
- **镜像构建**：在目标服务器构建Docker镜像，避免registry依赖
- **服务编排**：使用Docker Compose v2启动多容器应用
- **网络配置**：自动配置防火墙，开放必要端口
- **健康检查**：等待应用就绪并验证HTTP响应

### 🐧 多操作系统兼容性
智能识别并适配不同Linux发行版：
- **CentOS/RHEL**：使用yum安装，配置firewalld防火墙
- **Ubuntu**：使用apt安装docker-compose-plugin，配置ufw防火墙
- **Debian**：使用专用Docker仓库，二进制安装Docker Compose

### 🚨 实际问题解决
项目实践了以下典型问题的解决方案：

| 问题 | 解决方案 | 技术价值 |
|------|----------|----------|
| SSH主机密钥验证失败 | 配置`StrictHostKeyChecking=no`或预先接受密钥 | 实现非交互式自动化 |
| Docker Compose v1终止支持 | 迁移到`community.docker.docker_compose_v2`模块 | 保持技术栈现代性 |
| Debian系统误用Ubuntu仓库 | 精确识别`ansible_distribution`变量 | 提高跨平台可靠性 |
| 模块参数不兼容 | `restarted`→`recreate: "always"`参数更新 | 适配模块版本升级 |

### 🛡 生产环境最佳实践
- **安全隔离**：使用专用数据库用户，避免root权限
- **配置外置**：环境变量与代码分离，便于多环境部署
- **健康监控**：部署后自动验证应用可达性
- **防火墙管理**：仅开放必要端口（8080）

## ✅ 部署验证

### 部署成功标志
当playbook运行成功后，您将看到类似输出：
```
PLAY RECAP *********************************************************************
target_host      : ok=12   changed=8    unreachable=0    failed=0

TASK [显示部署成功信息] *********************************************************
ok: [target_host] => {
    "msg": "OneTapWebsite 已成功部署！访问地址：http://45.76.251.59:8080"
}
```

### 访问部署的网站
1. 在浏览器中打开部署成功的URL（如 `http://your_server_ip:8080`）
2. 您将看到完整的电子商务网站界面：

![OneTapWebsite部署成功截图](OneTapWebSite-Template.png)

3. 网站功能验证：
   - ✅ 响应式设计，适配移动设备
   - ✅ 产品展示和分类功能
   - ✅ 购物车和用户交互界面
   - ✅ 完整的LAMP栈应用功能

### 健康检查命令
```bash
# 手动验证应用状态
curl http://your_server_ip:8080
# 预期返回HTML内容，HTTP状态码200

# 检查Docker容器状态
ssh root@your_server_ip "docker ps"
# 应显示运行中的web和db容器
```

## 🔧 故障排除

### 常见问题

#### Q1: SSH连接失败
```
Failed to connect to the host via ssh: ssh_askpass: exec(/usr/bin/ssh-askpass)
```
**解决方案**：
```bash
# 确保已配置SSH密钥认证
ssh-copy-id root@your_server_ip

# 或在inventory.ini中添加（仅测试环境）
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

#### Q2: Docker仓库不可用
```
E:The repository 'https://download.docker.com/linux/ubuntu bookworm Release' does not have a Release file.
```
**解决方案**：Playbook已自动处理操作系统识别，确保使用正确的仓库URL。

#### Q3: 模块参数不支持
```
Unsupported parameters for (community.docker.docker_compose_v2) module: restarted
```
**解决方案**：项目已更新使用`recreate: "always"`参数。

### 调试命令
```bash
# 1. 测试Ansible连接
ansible -i inventory.ini all -m ping

# 2. 检查语法
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# 3. 试运行（不实际执行）
ansible-playbook -i inventory.ini playbook.yml --check

# 4. 详细日志输出
ansible-playbook -i inventory.ini playbook.yml -vvv
```

## 📊 项目成果展示

### 部署效率提升
| 指标 | 手动部署 | Ansible自动化 |
|------|----------|---------------|
| 部署时间 | 30-60分钟 | 5-10分钟 |
| 步骤数量 | 15+个手动步骤 | 1条命令 |
| 出错概率 | 高（人工操作） | 低（自动化） |
| 环境一致性 | 依赖操作者技能 | 完全一致 |

### 技术能力证明
1. **自动化思维**：将复杂部署流程转化为可重复的代码
2. **问题解决**：识别并解决真实环境中的兼容性问题
3. **最佳实践**：实施安全、可靠的生产环境配置
4. **跨平台能力**：适配不同Linux生态的差异

## 📄 许可证

本项目基于MIT许可证开源 - 查看[LICENSE](LICENSE)文件了解详情。

## 📚 扩展阅读

- [部署经验总结](部署经验总结.md) - 详细的技术问题分析和解决方案
- [Ansible官方文档](https://docs.ansible.com/) - 深入学习Ansible
- [Docker Compose v2迁移指南](https://docs.docker.com/compose/migrate/) - 了解v1到v2的变化

---

**部署案例**：本项目已在Debian 12 (bookworm)、Ubuntu 22.04、CentOS 7 上测试通过。

*最后更新：2025年12月*
