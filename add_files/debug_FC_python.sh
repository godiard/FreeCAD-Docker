#!/bin/bash
#
# This script will start both Winpdb and FreeCAD to debug a Python workbench
#
# TODO: How to use FREECAD_WINPDB_PORT?
winpdb &
${FREECAD_BUILD_DIR}/bin/FreeCAD /root/debug_FC_init.py
