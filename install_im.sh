#!/bin/bash
# Install ImageMagick on Snow Leopard (10.6)
# Reported to work also on Leopard (10.5)
#
# Created by Claudio Poli (http://www.icoretech.org)

# Configuration.
# Set the sourceforge.net's mirror to use.
SF_MIRROR="heanet"
# ImageMagick configure arguments.
# If you plan on using PerlMagick remove --without-perl
# In any case tweak as your liking.
IMAGEMAGICK_ARGUMENTS="--disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8 --disable-openmp"
# Installation path.
CONFIGURE_PREFIX=/usr/local # no trailing slash.
# GhostScript font path.
CONFIGURE_GS_FONT=$CONFIGURE_PREFIX/share/ghostscript
# Mac OS X version.
DEPLOYMENT_TARGET=10.6

# Starting.
echo "---------------------------------------------------------------------"
echo "ImageMagick installation started."
echo "Please note that there are incompatibilies with MacPorts."
echo "Read: http://github.com/masterkain/ImageMagick-sl/issues/#issue/1 - reported by Nico Ritsche"
echo "---------------------------------------------------------------------"

apps=()
# Function that tries to download a file, if not abort the process.
function try_download () {
  file_name=`echo "$1" | ruby -ruri -e 'puts File.basename(gets.to_s.chomp)'` # I cheated.
  rm -f $file_name # Cleanup in case of retry.
  echo "Downloading $1"
  curl --fail --progress-bar -O --url $1
  result=$? # Store the code of the last action, should be 0 for a successfull download.
  file_size=`ls -l "$file_name" | awk '{print $5}'`
  # We check for normal errors, otherwise check the file size.
  # Some websites like sourceforge redirects and curl can't
  # detect the problem.
  if [[ $result -ne 0 || $file_size -lt 500000 ]] # less than 500K
  then
    echo "Failed download: $1, size: "$file_size"B, aborting." >&2 # output on stderr.
    exit 65
  else
    apps=( "${apps[@]}" "$file_name" ) # add the filename to an array to be decompressed later.
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
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/freetype/freetype2/2.3.12/freetype-2.3.12.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz
try_download http://www.ijg.org/files/jpegsrc.v8b.tar.gz 
try_download http://download.osgeo.org/libtiff/tiff-3.9.4.tar.gz
try_download http://"$SF_MIRROR".dl.sourceforge.net/project/lcms/lcms/2.0/lcms2-2.0a.tar.gz
try_download http://ghostscript.googlecode.com/files/ghostscript-9.00.tar.gz
try_download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.4.7.tar.gz
try_download ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.6.6-10.tar.gz

# Decompress applications.
decompress_applications

echo "Starting..."

# LibPNG.
# Official PNG reference library.
cd libpng-1.4.7
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# JPEG.
# Library for JPEG image compression.
cd jpeg-8b
ln -s `which glibtool` ./libtool
export MACOSX_DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET
./configure --enable-shared --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# Little cms.
# A free color management engine in 100K.
cd lcms-2.0
make clean
./configure
make
sudo make install
cd ..

# GhostScript.
# Interpreter for the PostScript language and for PDF.
cd ghostscript-9.00
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# Ghostscript Fonts.
# Fonts and font metrics customarily distributed with Ghostscript.
sudo rm -rf $CONFIGURE_PREFIX/share/ghostscript/fonts # cleanup
sudo mv fonts $CONFIGURE_GS_FONT

# The FreeType Project.
# A free, high-quality and portable font engine.
cd freetype-2.3.12
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# libwmf.
# library to convert wmf files
cd libwmf-0.2.8.4
make clean
./configure --without-expat --with-xml --with-png=/usr/X11
make
sudo make install
cd ..

# LibTIFF.
# Support for the Tag Image File Format (TIFF)
cd tiff-3.9.4
./configure --prefix=$CONFIGURE_PREFIX
make
sudo make install
cd ..

# ImageMagick.
# Software suite to create, edit, and compose bitmap images.
cd ImageMagick-6.6.6-10
export CPPFLAGS=-I$CONFIGURE_PREFIX/include
export LDFLAGS=-L$CONFIGURE_PREFIX/lib
./configure --prefix=$CONFIGURE_PREFIX $IMAGEMAGICK_ARGUMENTS --with-gs-font-dir=$CONFIGURE_GS_FONT/fonts
make
sudo make install
cd ..

echo "ImageMagick installed."
convert -version

echo "Testing..."
$CONFIGURE_PREFIX/bin/convert logo: logo.gif
$CONFIGURE_PREFIX/bin/convert logo: logo.jpg
$CONFIGURE_PREFIX/bin/convert logo: logo.png
$CONFIGURE_PREFIX/bin/convert logo: logo.tiff
echo "Tests done."

exit
