#!/bin/bash
# ============================================================
# MCP Workshop — Lab 4 Cumulative Script
# Sets up environment + deploys DB MCP as persistent service
# ============================================================
set -e

echo "================================================"
echo "  Lab 4: Deploy as Persistent Service"
echo "================================================"

# Ensure venv exists
source ~/mcpenv/bin/activate 2>/dev/null || {
    echo "Virtual environment not found. Run Labs 1-3 first."
    exit 1
}

# Create startup script
cat > ~/mcp-servers/start_db_mcp.sh << 'EOF'
#!/bin/bash
echo "MCP Server starting at $(date)" >> /tmp/mcp_server.log
cd /home/opc/mcp-servers
export PYTHONUNBUFFERED=1
source /home/opc/mcpenv/bin/activate
python -u db_mcp.py 2>&1 | tee -a /tmp/mcp_server.log
EOF
chmod +x ~/mcp-servers/start_db_mcp.sh

# Create systemd service
sudo tee /etc/systemd/system/mcp-server.service << 'EOF'
[Unit]
Description=Oracle Database MCP Server
After=network.target

[Service]
Type=simple
User=opc
WorkingDirectory=/home/opc/mcp-servers
ExecStart=/home/opc/mcp-servers/start_db_mcp.sh
Restart=always
RestartSec=10
StandardOutput=append:/tmp/mcp_server.log
StandardError=append:/tmp/mcp_server.log
EnvironmentFile=/home/opc/mcp-servers/.env

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable mcp-server
sudo systemctl start mcp-server

echo "================================================"
echo "  ✅ MCP Server deployed as persistent service!"
echo "  Check status: sudo systemctl status mcp-server"
echo "================================================"
