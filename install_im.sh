#!/bin/bash
# Installs ImageMagick on Snow Leopard
# Created by Claudio Poli (http://www.icoretech.org)

# Set the sourceforge.net's mirror to use.
SF_MIRROR="heanet"
# ImageMagick configure arguments.
IMAGEMAGICK_ARGUMENTS="--disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8"
# Installation path.
CONFIGURE_PREFIX="/usr/local" # no trailing slash.

apps=()
# Function that tries to download a file, if not abort the process.
function try_download () {
  file_name=`echo "$1" | ruby -ruri -e 'puts File.basename(gets.to_s.chomp)'` # I cheated.
  rm -f $file_name # Cleanup in case of retry.
  echo "Downloading $1"
  curl --fail --silent -O --url $1
  result=$? # Store the code of the last action, should be 0 for a successfull download.
  file_size=`ls -l "$file_name" | awk '{print $5}'`
  # We check for normal http errors, otherwise check the file size
  # since some websites, like sourceforge, redirects and curl can't
  # detect the problem.
  if [[ $result -ne 0 || $file_size -lt 500000 ]] # less than 500K
  then
    echo "Failed download: $1, size: "$file_size"B, aborting." >&2 # output on stderr.
    exit 65
  else
    # add the filename to an array to be decompressed later.
    apps=( "${apps[@]}" "$file_name" )
  fi
}

function decompress_applications () {
  # decompress the array of apps.
  for item in ${apps[*]}
  do
    echo "Decompressing $item"
    tar zxf $item
  done
}

# Before running anything try to download all requires files, saving time.
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz
try_download http://www.ijg.org/files/jpegsrc.v7.tar.gz
try_download http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz
try_download http://www.littlecms.com/lcms-1.18a.tar.gz
try_download http://ghostscript.com/releases/ghostscript-8.70.tar.gz
try_download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.40.tar.gz
try_download ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.5.4-10.tar.gz

# Decompress applications.
decompress_applications

echo "Starting..."

# The FreeType Project.
# A free, high-quality and portable font engine.
cd freetype-2.3.9
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# LibPNG.
# Official PNG reference library.
cd libpng-1.2.40
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# JPEG.
# Library for JPEG image compression.
cd jpeg-7
ln -s `which glibtool` ./libtool
export MACOSX_DEPLOYMENT_TARGET=10.6
./configure --enable-shared --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# LibTIFF.
# Support for the Tag Image File Format (TIFF)
cd tiff-3.8.2
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# libwmf.
# library to convert wmf files
cd libwmf-0.2.8.4
make clean
./configure
make
sudo make install
cd ..

# Little cms.
# A free color management engine in 100K.
cd lcms-1.18
make clean
./configure
make
sudo make install
cd ..

# GhostScript.
# Interpreter for the PostScript language and for PDF.
cd ghostscript-8.70
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# Ghostscript Fonts.
# Fonts and font metrics customarily distributed with Ghostscript.
sudo rm -rf $CONFIGURE_PREFIX/share/ghostscript/fonts # cleanup
sudo mv fonts $CONFIGURE_PREFIX/share/ghostscript

# ImageMagick.
# Software suite to create, edit, and compose bitmap images.
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