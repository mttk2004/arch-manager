#!/bin/bash
echo "Building Arch Zsh Manager standalone binary..."
source venv/bin/activate
pip install pyinstaller
pyinstaller --name pkgman --onefile --add-data "lib:lib" pkgman.py
echo "Done! Executable is at dist/pkgman"
