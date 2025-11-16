#!/bin/bash
# 守护进程启动脚本

cd "$(dirname "$0")"

# 检查虚拟环境
if [ ! -d "../venv" ]; then
    echo "错误: 虚拟环境不存在"
    exit 1
fi

# 激活虚拟环境
source ../venv/bin/activate

# 检查是否已在运行
if pgrep -f "uvicorn app.main:app" > /dev/null; then
    echo "⚠️  应用已在运行中"
    ps aux | grep "uvicorn app.main:app" | grep -v grep
    exit 1
fi

# 创建日志目录
mkdir -p logs

# 启动守护进程
echo "🚀 启动守护进程..."
nohup uvicorn app.main:app --host 0.0.0.0 --port 7001 > logs/app.log 2>&1 &

# 等待启动
sleep 3

# 检查是否启动成功
if pgrep -f "uvicorn app.main:app" > /dev/null; then
    echo "✅ 应用启动成功 (PID: $(pgrep -f "uvicorn app.main:app"))"
    echo "📝 日志文件: logs/app.log"
    echo "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):7001"
else
    echo "❌ 应用启动失败"
    echo "查看日志: tail -f logs/app.log"
    exit 1
fi