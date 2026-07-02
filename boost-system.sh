#!/bin/bash
# ============================================================
# NIKKE FPS Boost — System-level optimizations
# Run with: sudo ./boost-system.sh
# Run BEFORE launching game for best results
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run with sudo: sudo $0${NC}"
    exit 1
fi

echo -e "${CYAN}╔══════════════════════════════════════════════╗"
echo -e "║  🚀 NIKKE FPS Boost — System Optimizations   ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. CPU Governor → performance
echo -e "${YELLOW}[1/5]${NC} Setting CPU governor to performance..."
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" > "$gov" 2>/dev/null
done
echo -e "${GREEN}  ✓ CPU governor: performance${NC}"

# 2. Unlock CPU frequency to maximum
echo -e "${YELLOW}[2/5]${NC} Unlocking CPU frequency..."
MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo "0")
for freq_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    echo "$MAX_FREQ" > "$freq_file" 2>/dev/null
done
CUR_MAX=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo "?")
echo -e "${GREEN}  ✓ CPU max freq: ${CUR_MAX}kHz (hardware max: ${MAX_FREQ}kHz)${NC}"

# 3. Enable turbo boost
echo -e "${YELLOW}[3/5]${NC} Enabling turbo boost..."
if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
    echo -e "${GREEN}  ✓ Intel P-State turbo: enabled${NC}"
elif [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null
    echo -e "${GREEN}  ✓ CPU boost: enabled${NC}"
else
    echo -e "${YELLOW}  ⚠ No turbo boost control found${NC}"
fi

# 4. Memory optimizations
echo -e "${YELLOW}[4/5]${NC} Optimizing memory..."

# Lower swappiness (keep things in RAM)
sysctl -w vm.swappiness=10 > /dev/null 2>&1
echo -e "${GREEN}  ✓ vm.swappiness=10 (was $(sysctl -n vm.swappiness))${NC}"

# Increase max_map_count for Wine
CURRENT_MAP=$(sysctl -n vm.max_map_count)
if [ "$CURRENT_MAP" -lt 2147483642 ]; then
    sysctl -w vm.max_map_count=2147483642 > /dev/null 2>&1
    echo -e "${GREEN}  ✓ vm.max_map_count=2147483642${NC}"
else
    echo -e "${GREEN}  ✓ vm.max_map_count already optimal ($CURRENT_MAP)${NC}"
fi

# Compact memory / drop caches
sync
echo 1 > /proc/sys/vm/drop_caches 2>/dev/null
echo -e "${GREEN}  ✓ Page cache dropped (freed RAM)${NC}"

# 5. I/O scheduler
echo -e "${YELLOW}[5/5]${NC} Optimizing I/O scheduler..."
for sched in /sys/block/nvme*/queue/scheduler; do
    if [ -f "$sched" ]; then
        echo "none" > "$sched" 2>/dev/null
        echo -e "${GREEN}  ✓ NVMe scheduler: none (lowest latency)${NC}"
    fi
done

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗"
echo -e "║  ${GREEN}✅ System optimized for gaming!${CYAN}              ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Now launch NIKKE:"
echo -e "  ${GREEN}flatpak run net.lutris.Lutris lutris:nikke${NC}"
echo ""
