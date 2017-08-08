#!/bin/bash
export TMPDIR=/Users/zhaowenchao/Documents/ffmpeg/ffmpeg-3.0/ffmpegtemp #这句很重要，不然会报错 unable to create temporary file in
# NDK的路径，根据自己的安装位置进行设置
NDK=/Users/zhaowenchao/Library/Android/sdk/ndk-bundle
# 编译针对的平台，可以根据自己的需求进行设置
# 这里选择最低支持android-14, arm架构，生成的so库是放在
# libs/armeabi文件夹下的，若针对x86架构，要选择arch-x86
PLATFORM=$NDK/platforms/android-21/arch-arm64/
# 工具链的路径，根据编译的平台不同而不同
# arm-linux-androideabi-4.9与上面设置的PLATFORM对应，4.9为工具的版本号，
# 根据自己安装的NDK版本来确定，一般使用最新的版本
TOOLCHAIN=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64
function build_one
{
./configure \
    --prefix=$PREFIX \
    --target-os=linux \
    --cross-prefix=$TOOLCHAIN/bin/aarch64-linux-android- \
    --arch=aarch64 \
    --extra-libs="-lgcc" \
    --sysroot=$PLATFORM \
    --cc=$TOOLCHAIN/bin/aarch64-linux-android-gcc-4.9.x \
    --nm=$TOOLCHAIN/bin/aarch64-linux-android-nm \
    --extra-cflags="-I../x264/android/arm64/include" \
    --extra-ldflags="-L../x264/android/arm64/lib" \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
    --extra-ldflags="-lx264 -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
    --disable-shared \
    --enable-runtime-cpudetect \
    --enable-gpl \
    --enable-libx264 \
    --enable-small \
    --enable-cross-compile \
    --disable-debug \
    --enable-static \
    --disable-doc \
    --enable-asm \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-postproc \
    --disable-avdevice \
    --disable-symver \
    --disable-stripping \
$ADDITIONAL_CONFIGURE_FLAG
sed -i '' 's/HAVE_LRINT 0/HAVE_LRINT 1/g' config.h
sed -i '' 's/HAVE_LRINTF 0/HAVE_LRINTF 1/g' config.h
sed -i '' 's/HAVE_ROUND 0/HAVE_ROUND 1/g' config.h
sed -i '' 's/HAVE_ROUNDF 0/HAVE_ROUNDF 1/g' config.h
sed -i '' 's/HAVE_TRUNC 0/HAVE_TRUNC 1/g' config.h
sed -i '' 's/HAVE_TRUNCF 0/HAVE_TRUNCF 1/g' config.h
sed -i '' 's/HAVE_CBRT 0/HAVE_CBRT 1/g' config.h
sed -i '' 's/HAVE_RINT 0/HAVE_RINT 1/g' config.h
make clean
make -j8
make install
}


CPU=arm64-v8a
OPTIMIZE_CFLAGS=
#”-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
PREFIX=./android/$CPU-vfp
ADDITIONAL_CONFIGURE_FLAG=
build_one





$TOOLCHAIN/bin/aarch64-linux-android-ld \
-rpath-link=$PLATFORM/usr/lib \
-L$PLATFORM/usr/lib \
-L$PREFIX/lib \
-soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
$PREFIX/libffmpeg.so \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libswscale/libswscale.a \
    ../x264/libx264.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/aarch64-linux-android/4.9.x/libgcc.a \
