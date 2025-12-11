#!/bin/bash
# Web前端API测试脚本
# 测试删除WiFi/设备接入/恢复出厂设置后的剩余API

BASE_URL="${1:-http://192.168.1.1}"

echo "=========================================="
echo "5G-MIFI Web API 测试脚本"
echo "目标地址: $BASE_URL"
echo "=========================================="

# 测试函数
test_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    local desc=$4
    
    echo -n "[$method] $endpoint - $desc ... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint" 2>/dev/null)
    else
        response=$(curl -s -w "\n%{http_code}" -X $method -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint" 2>/dev/null)
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo "✓ OK"
    else
        echo "✗ FAIL (HTTP $http_code)"
    fi
}

echo ""
echo "=== 系统信息API ==="
test_api GET "/api/info" "" "获取系统信息"
test_api GET "/api/serial" "" "获取设备序列号"

echo ""
echo "=== 网络管理API ==="
test_api GET "/api/bands" "" "获取频段状态"
test_api GET "/api/current_band" "" "获取当前频段"
test_api GET "/api/cells" "" "获取小区信息"

echo ""
echo "=== 流量统计API ==="
test_api GET "/api/get/Total" "" "获取流量统计"
test_api GET "/api/get/set" "" "获取流量配置"

echo ""
echo "=== 充电控制API ==="
test_api GET "/api/charge/config" "" "获取充电配置"

echo ""
echo "=== 定时重启API ==="
test_api GET "/api/get/first-reboot" "" "获取定时重启配置"
test_api GET "/api/get/time" "" "获取系统时间"

echo ""
echo "=== 已删除的API（应返回404）==="
test_api GET "/api/wifi/status" "" "WiFi状态(已删除)"
test_api GET "/api/wifi/clients" "" "WiFi客户端(已删除)"
test_api GET "/api/wifi/blacklist" "" "黑名单(已删除)"
test_api GET "/api/factory-reset" "" "恢复出厂(已删除)"

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
