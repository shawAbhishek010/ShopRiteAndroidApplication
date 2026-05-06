#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"
echo "Razorpay test server will listen on the host configured in python_payment_server/razorpay_server_config.py"
python python_payment_server/razorpay_test_server.py
