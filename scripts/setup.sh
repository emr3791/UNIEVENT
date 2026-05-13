#!/usr/bin/env bash

# Basit geliştirme ortamı kurulum scripti (Unix tabanlı)
# Windows kullanıcıları PowerShell veya WSL kullanabilir.

echo "Installing Python deps (in venv)..."
python -m venv .venv
source .venv/bin/activate
pip install -r ai/python/requirements.txt

echo "Installing backend deps..."
cd backend/nodejs
npm install
cd -

echo "Done. Check README files for next steps."
