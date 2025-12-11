# ofono-server (C 版本)

Go 程序 `server` 的 C 语言移植版本，使用 GLib/GIO D-Bus 库和 mongoose HTTP 服务器。

## 编译

```bash
make -C src server
```

## 运行

```bash
# 默认监听 80 端口
./ofono-server

# 指定端口
./ofono-server 8080
```

## API 列表

| 路由 | 方法 | 说明 | 状态 |
|------|------|------|------|
| `/api/info` | GET | 获取系统信息 | ✅ |
| `/api/at` | POST | 执行 AT 命令 | ✅ |
| `/api/current_band` | GET | 获取当前连接频段详情 | ✅ |
| `/api/bands` | GET | 获取频段锁定状态 | ✅ |
| `/api/lock_bands` | POST | 锁定指定频段 | ✅ |
| `/api/unlock_bands` | POST | 解锁所有频段 | ✅ |
| `/api/cells` | GET | 获取小区信息 | ✅ |
| `/api/lock_cell` | POST | 锁定指定小区 | ✅ |
| `/api/unlock_cell` | POST | 解锁小区 | ✅ |
| `/api/get/Total` | GET | 获取流量统计 | ✅ |
| `/api/get/set` | GET | 获取流量配置 | ✅ |
| `/api/set/total` | GET | 设置流量限制 | ✅ |
| `/api/get/first-reboot` | GET | 获取定时重启配置 | ✅ |
| `/api/set/reboot` | GET | 设置定时重启 | ✅ |
| `/api/claen/cron` | GET | 清除定时任务 | ✅ |
| `/api/charge/config` | GET/POST | 获取/设置充电配置 | ✅ |
| `/api/charge/on` | POST | 手动开启充电 | ✅ |
| `/api/charge/off` | POST | 手动停止充电 | ✅ |
| `/api/set_network` | POST | 设置网络模式 | ✅ |
| `/api/switch` | POST | 切换 SIM 卡槽 | ✅ |
| `/api/airplane_mode` | POST | 飞行模式控制 | ✅ |
| `/api/device_control` | POST | 设备控制 (重启/关机) | ✅ |
| `/api/clear_cache` | POST | 清除系统缓存 | ✅ |

## API 请求示例

### 获取系统信息
```bash
curl http://localhost/api/info
```

### 执行 AT 命令
```bash
curl -X POST http://localhost/api/at \
  -H "Content-Type: application/json" \
  -d '{"command": "AT+CSQ"}'
```

### 设置网络模式
```bash
# 可选模式: lte_only, nr_5g_only, nr_5g_lte_auto, nsa_only
curl -X POST http://localhost/api/set_network \
  -H "Content-Type: application/json" \
  -d '{"mode": "nr_5g_lte_auto"}'
```

### 切换 SIM 卡槽
```bash
curl -X POST http://localhost/api/switch \
  -H "Content-Type: application/json" \
  -d '{"slot": "slot1"}'
```

### 飞行模式
```bash
# 开启飞行模式
curl -X POST http://localhost/api/airplane_mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'

# 关闭飞行模式
curl -X POST http://localhost/api/airplane_mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```

### 设备控制
```bash
# 重启
curl -X POST http://localhost/api/device_control \
  -H "Content-Type: application/json" \
  -d '{"action": "reboot"}'

# 关机
curl -X POST http://localhost/api/device_control \
  -H "Content-Type: application/json" \
  -d '{"action": "poweroff"}'
```

### 清除缓存
```bash
curl -X POST http://localhost/api/clear_cache
```

### 获取当前连接频段
```bash
curl http://localhost/api/current_band
```

响应示例:
```json
{
  "Code": 0,
  "Error": "",
  "Data": {
    "network_type": "5G NR",
    "band": "N78",
    "arfcn": 627264,
    "pci": 123,
    "rsrp": -95.50,
    "rsrq": -11.20,
    "sinr": 15.30
  }
}
```

## 文件结构

```
src/
├── main.c           # 主程序入口
├── http_server.c/h  # HTTP 服务器
├── handlers.c/h     # API 处理器
├── dbus_core.c/h    # D-Bus 核心
├── sysinfo.c/h      # 系统信息
├── airplane.c/h     # 飞行模式/SIM 信息
├── modem.c/h        # 网络模式/卡槽切换
├── exec_utils.c/h   # 命令执行工具
├── mongoose.c/h     # HTTP 库
└── Makefile
```

## 依赖

- GLib 2.54.3 (aarch64-linux-gnu)
- GCC 7.2.1

## 更新日志

### 2024-12-06
- 修复 CPU 使用率获取：按字段索引解析 top 输出（与 Go 实现一致）
- 修复 `/api/current_band`：实现完整的 AT 命令数据解析
  - 5G: `AT+SPENGMD=0,14,1` 解析 band/arfcn/pci/rsrp/rsrq/sinr
  - 4G: `AT+SPENGMD=0,6,0` 解析相同字段
- 新增 `parse_cell_to_vec()` 函数，与 Go 的 `parseCellToVec` 逻辑一致
- 新增高级网络 API (advanced.c):
  - `/api/bands` - 获取频段锁定状态
  - `/api/lock_bands` - 锁定指定频段
  - `/api/unlock_bands` - 解锁所有频段
  - `/api/cells` - 获取小区信息（主小区+邻小区）
  - `/api/lock_cell` - 锁定指定小区
  - `/api/unlock_cell` - 解锁小区
- 新增流量控制 API (traffic.c):
  - `/api/get/Total` - 获取流量统计
  - `/api/get/set` - 获取流量配置
  - `/api/set/total` - 设置流量限制
- 新增定时重启 API (reboot.c):
  - `/api/get/first-reboot` - 获取定时重启配置
  - `/api/set/reboot` - 设置定时重启
  - `/api/claen/cron` - 清除定时任务
- 新增充电控制 API (charge.c):
  - `/api/charge/config` - 获取/设置充电配置
  - `/api/charge/on` - 手动开启充电
  - `/api/charge/off` - 手动停止充电
