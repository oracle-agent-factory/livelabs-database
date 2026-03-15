#!/bin/bash
# ============================================================
# MCP Workshop — Lab 1 Setup Script
# Automatically sets up the MCP development environment
# ============================================================
set -e

echo "================================================"
echo "  MCP Development Environment Setup"
echo "================================================"

# Install Python 3.11
echo "[1/5] Installing Python 3.11..."
sudo dnf install -y python3.11 python3.11-pip python3.11-devel

# Create virtual environment
echo "[2/5] Creating virtual environment..."
python3.11 -m venv ~/mcpenv
source ~/mcpenv/bin/activate

# Install packages
echo "[3/5] Installing FastMCP and dependencies..."
pip install --upgrade pip
pip install fastmcp oracledb python-dotenv

# Open firewall ports
echo "[4/5] Opening firewall ports 8004-8009..."
sudo firewall-cmd --permanent --add-port=8004-8009/tcp
sudo firewall-cmd --reload

# Create project directory
echo "[5/5] Creating project directory..."
mkdir -p ~/mcp-servers

echo "================================================"
echo "  ✅ Setup complete! Activate with:"
echo "  source ~/mcpenv/bin/activate"
echo "  cd ~/mcp-servers"
echo "================================================"
