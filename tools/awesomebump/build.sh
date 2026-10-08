#!/bin/bash
# AwesomeBump AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), Qt 5.15, g++ 13.
#
# The upstream CMakeLists.txt is stale/broken for a from-source build
# (missing sources, missing Qt5Script, a source-list-clobbering bug, no
# include dirs for the QtnProperty unity build, AUTOMOC misses, VERSION_STRING
# never defined, and the .pef codegen step is never invoked). The patch below
# fixes the BUILD SYSTEM ONLY — no application code is changed.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
export TMPDIR="${TMPDIR:-$WORK/tmp}"; mkdir -p "$TMPDIR"

# 1. Qt5 + OpenGL dev packages
sudo apt-get install -y qtbase5-dev qtbase5-dev-tools libqt5opengl5-dev \
  libgl1-mesa-dev qtscript5-dev

# 2. Clone (with the QtnProperty submodule)
mkdir -p "$WORK/awesomebump" && cd "$WORK/awesomebump"
[ -d repo ] || git clone https://github.com/kmkolasinski/AwesomeBump repo
cd repo && git checkout f9fad16e066e366636dad05cb4c53c9e0aa2d729
git submodule update --init --depth 1
cd ..

# 3. Generate the .peg.{h,cpp} property files with the upstream QtnPEG
#    code generator (the cmake build never invokes it)
cd repo/Sources/properties
for f in *.pef; do ../utils/QtnProperty/bin-linux/QtnPEG "$f"; done
cd ../..

# 4. Apply the build-system patch (embedded below)
patch -p1 -d repo <<'PATCH_EOF'
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 59d4f47..f75499e 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -37,6 +37,7 @@ find_package(Qt5Widgets REQUIRED)
 find_package(Qt5OpenGL REQUIRED)
 find_package(Qt5Gui REQUIRED)
 find_package(Qt5DBus REQUIRED)
+find_package(Qt5Script REQUIRED)
 find_package(OpenGL REQUIRED)
 
 # Including support for OpenGL 3.3.0
@@ -47,30 +48,40 @@ endif()
 
 # Including source files and setting flags for the build
 add_definitions(${Qt5Widgets_DEFINITIONS} -DRESOURCE_BASE="${RESOURCE_BASE}/")
+add_definitions(-DVERSION_STRING=\"5.1\")
 qt5_wrap_ui(UI_HEADERS Sources/allaboutdialog.ui Sources/dialogheightcalculator.ui Sources/dialoglogger.ui
     Sources/dialogshortcuts.ui Sources/formimageprop.ui
     Sources/formmaterialindicesmanager.ui Sources/formsettingscontainer.ui Sources/formsettingsfield.ui
-    Sources/mainwindow.ui Sources/dockwidget3dsettings.ui)
+    Sources/mainwindow.ui Sources/dockwidget3dsettings.ui
+    Sources/formimagebatch.ui Sources/properties/Dialog3DGeneralSettings.ui)
 qt5_add_resources(UI_RESOURCES Sources/content.qrc)
 
+# Added for AppImage-from-source build: QtnProperty unity build needs these include dirs
+file(GLOB_RECURSE UTIL_DIRS LIST_DIRECTORIES true "${CMAKE_SOURCE_DIR}/Sources/utils/*")
+foreach(d ${UTIL_DIRS})
+  if(IS_DIRECTORY ${d})
+    include_directories(${d})
+  endif()
+endforeach()
+include_directories(${CMAKE_SOURCE_DIR}/Sources)
+include_directories(${CMAKE_SOURCE_DIR}/Sources/utils)
+include_directories(${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Core ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Core/Auxiliary ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Core/Core ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Core/GUI ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Demo ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Demo/AB ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Docs ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Docs/img ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PEG ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Delegates ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Delegates/Core ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Delegates/GUI ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Delegates/Utils ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Utils ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Tests ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Tests/PEG ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Tests/suite_squish_test_suit ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Tests/suite_squish_test_suit/tst_gui_test ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-linux ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-osx ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/custom_build_rules ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/custom_build_rules/win_bison_only ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/custom_build_rules/win_flex_only ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/data ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/data/m4sugar ${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-win/win_flex/data/xslt)
+
 set(CMAKE_CXX_FLAGS "${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")
-set(AwesomeBump_SRCS
-    Sources/utils/Mesh.cpp Sources/utils/qglbuffers.cpp
-    Sources/utils/tinyobj/tiny_obj_loader.cc Sources/CommonObjects.cpp
-    Sources/allaboutdialog.cpp Sources/camera.cpp Sources/dialogheightcalculator.cpp
-    Sources/camera.cpp Sources/dialogheightcalculator.cpp Sources/camera.cpp
-    Sources/dialogheightcalculator.cpp Sources/camera.cpp Sources/gpuinfo.cpp
-    Sources/dialogheightcalculator.cpp Sources/dialoglogger.cpp Sources/dialogshortcuts.cpp
-    Sources/dialoglogger.cpp Sources/dialogshortcuts.cpp
-    Sources/formimagebase.cpp Sources/formimagebase.cpp Sources/formimageprop.cpp
-    Sources/formmaterialindicesmanager.cpp Sources/formsettingscontainer.cpp
-    Sources/formsettingsfield.cpp Sources/glimageeditor.cpp Sources/glwidget.cpp
-    Sources/glwidgetbase.cpp Sources/mainwindow.cpp Sources/main.cpp
-    Sources/dockwidget3dsettings.cpp) 
+# NOTE (AppImage-from-source build): the upstream file list was stale
+# (missing formimagebatch, Dialog3DGeneralSettings, glsl parsers, contextinfo
+# widgets, AB property delegates, ...); glob the source tree instead.
+file(GLOB AwesomeBump_SRCS
+    Sources/*.cpp
+    Sources/utils/*.cpp
+    Sources/utils/*/*.cpp
+    Sources/properties/*.cpp
+    Sources/utils/tinyobj/*.cc)
+list(FILTER AwesomeBump_SRCS EXCLUDE REGEX ".*\\.peg\\.cpp$")
+list(FILTER AwesomeBump_SRCS EXCLUDE REGEX ".*/QtnProperty/.*") 
 # Check for QtnProperty (required)
 if(EXISTS "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/QtnPropertyUnity.cpp")
- set(AwesomeBump_SRCS
- 	Sources/utils/QtnProperty/QtnPropertyUnity.cpp)
+ list(APPEND AwesomeBump_SRCS Sources/utils/QtnProperty/QtnPropertyUnity.cpp)
  # choose QtnPeg binary
  if(APPLE)
 	 set(QTNPEG "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/bin-osx/QtnPEG")
@@ -110,8 +121,15 @@ else()
 endif()
 
 # Configure the linker and finalize binary compilation
-add_executable(awesomebump ${AwesomeBump_SRCS} ${UI_HEADERS} ${UI_RESOURCES} Sources/resources/icons/icon.icns)
-target_link_libraries(awesomebump Qt5::Core Qt5::DBus Qt5::Gui Qt5::Widgets Qt5::OpenGL
+file(GLOB_RECURSE QTN_HEADERS "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/Core/*.h"
+    "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/*.h"
+    "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Delegates/*.h"
+    "${CMAKE_SOURCE_DIR}/Sources/utils/QtnProperty/PropertyWidget/Utils/*.h")
+# .peg.cpp files are generated from Sources/properties/*.pef by the upstream
+# QtnPEG code generator (see build.sh); compile them like normal sources.
+file(GLOB PEG_SRCS "${CMAKE_SOURCE_DIR}/Sources/properties/*.peg.cpp")
+add_executable(awesomebump ${AwesomeBump_SRCS} ${UI_HEADERS} ${UI_RESOURCES} ${QTN_HEADERS} ${PEG_SRCS} Sources/resources/icons/icon.icns)
+target_link_libraries(awesomebump Qt5::Core Qt5::DBus Qt5::Gui Qt5::Widgets Qt5::OpenGL Qt5::Script
     GL)
 
 # Create an install target for "Release" builds using custom or default binary and

PATCH_EOF

# 5. Configure + build (RESOURCE_BASE=. => resources resolve relative to cwd;
#    the AppRun cds into the resource dir before launching)
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release -DRESOURCE_BASE=.
cmake --build build -j"$(nproc)"
# -> build/awesomebump

# 6. Package: pack.sh for the skeleton + lib bundling, then customize
cd "$WORK"
./pack.sh AwesomeBump awesomebump/build/awesomebump
# resources (Bin/Core/...) must sit next to the binary: RESOURCE_BASE=./
cp -r awesomebump/repo/Bin/* AwesomeBump.AppDir/usr/bin/
# AppRun cds into usr/bin so ./Core/... resolves
cat > AwesomeBump.AppDir/AppRun <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
export PATH="$HERE/usr/bin:$PATH"
cd "$HERE/usr/bin"
exec "$HERE/usr/bin/awesomebump" "$@"
EOF
chmod +x AwesomeBump.AppDir/AppRun
sed -i 's/Terminal=true/Terminal=false/' AwesomeBump.AppDir/AwesomeBump.desktop
sed -i 's/Comment=AwesomeBump mesh tool (command line)/Comment=AwesomeBump normal-map generator/' \
  AwesomeBump.AppDir/AwesomeBump.desktop
# rebuild the AppImage with the customized AppDir
ARCH=x86_64 ./appimagetool-root/AppRun AwesomeBump.AppDir AwesomeBump-x86_64.AppImage
# -> $WORK/AwesomeBump-x86_64.AppImage
