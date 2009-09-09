#!/bin/bash
# Installs ImageMagick on Snow Leopard

# Set the sourceforge.net's mirror to use.
SF_MIRROR="heanet"
# ImageMagick configure arguments.
IMAGEMAGICK_ARGUMENTS="--disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8"
# Installation path.
CONFIGURE_PREFIX="/usr/local" # no trailing slash.

# Function that tries to download a file, if not abort the process.
function try_download () {
  rm -f $1
  echo "Downloading $1"
  curl --fail --silent -O --url $1
  result=$?
  file_name=`echo "$1" | ruby -ruri -e 'puts File.basename(gets.to_s.chomp)'` # I cheated.
  file_size=`ls -l "$file_name" | awk '{print $5}'`
  # We check for normal http errors, otherwise check the file size
  # since some websites, like sourceforge, redirects and curl can't
  # detect the problem.
  if [[ $result -ne 0 || $file_size -lt 500000 ]] # less than 500K
  then
    echo "Failed download: $1, size: "$file_size"B, aborting." >&2
    exit 65
  fi
}

# Before running anything try to download all requires files.
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz
try_download http://www.ijg.org/files/jpegsrc.v7.tar.gz
try_download http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz
try_download http://www.littlecms.com/lcms-1.18a.tar.gz
try_download http://ghostscript.com/releases/ghostscript-8.70.tar.gz
try_download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.39.tar.bz2
try_download ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.5.4-10.tar.gz

# Freetype.
tar zxf freetype-2.3.9.tar.gz
cd freetype-2.3.9
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# LibPNG.
tar jxf libpng-1.2.39.tar.bz2
cd libpng-1.2.39
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# JPEGsrc.
tar zxf jpegsrc.v7.tar.gz
cd jpeg-7
ln -s `which glibtool` ./libtool
export MACOSX_DEPLOYMENT_TARGET=10.6
./configure --enable-shared --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# LibTIFF.
tar zxf tiff-3.8.2.tar.gz
cd tiff-3.8.2
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# LibWMF.
tar zxf libwmf-0.2.8.4.tar.gz
cd libwmf-0.2.8.4
make clean
./configure
make
sudo make install
cd ..

# LCMS.
tar zxf lcms-1.18a.tar.gz
cd lcms-1.18
make clean
./configure
make
sudo make install
cd ..

# GhostScript.
tar zxf ghostscript-8.70.tar.gz
cd ghostscript-8.70
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# GhostScript Fonts.
tar zxf ghostscript-fonts-std-8.11.tar.gz
sudo mv fonts $CONFIGURE_PREFIX/share/ghostscript

# ImageMagick.
tar zxf ImageMagick-6.5.4-10.tar.gz
cd ImageMagick-6.5.4-10
export CPPFLAGS=-I$CONFIGURE_PREFIX/include
export LDFLAGS=-L$CONFIGURE_PREFIX/lib
./configure --prefix=$CONFIGURE_PREFIX $IMAGEMAGICK_ARGUMENTS --with-gs-font-dir=/usr/local/share/ghostscript/fonts
make
sudo make install
cd ..

echo "ImageMagick installed."
convert -version
exit