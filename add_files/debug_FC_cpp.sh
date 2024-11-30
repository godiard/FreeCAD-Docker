#!/bin/bash
#
# This script starts both gdbgui and FreeCAD to debug CPP code
#
gdbgui --port $FREECAD_GDB_PORT --remote --project ${FREECAD_BUILD_DIR} --args ${FREECAD_BUILD_DIR}/bin/FreeCAD
