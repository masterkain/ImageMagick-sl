## install imagemagick on snow leopard ( kain )

#!/bin/sh
curl -O http://heanet.dl.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.gz
tar zxvf freetype-2.3.9.tar.gz
cd freetype-2.3.9
./configure --prefix=/usr/local
make
sudo make install
cd ..

curl -O ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.39.tar.bz2
tar jxvf libpng-1.2.39.tar.bz2
cd libpng-1.2.39
./configure --prefix=/usr/local
make
sudo make install
cd ..

curl -O http://www.ijg.org/files/jpegsrc.v7.tar.gz
tar xzvf jpegsrc.v7.tar.gz
cd jpeg-7
ln -s `which glibtool` ./libtool
export MACOSX_DEPLOYMENT_TARGET=10.6
./configure --enable-shared --prefix=/usr/local
make
sudo make install
cd ..

curl -O http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz
tar xzvf tiff-3.8.2.tar.gz
cd tiff-3.8.2
./configure --prefix=/usr/local
make
sudo make install
cd ..

curl -O http://heanet.dl.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz
tar xzvf libwmf-0.2.8.4.tar.gz
cd libwmf-0.2.8.4
make clean
./configure
make
sudo make install
cd ..

curl -O http://www.littlecms.com/lcms-1.18a.tar.gz
tar xzvf lcms-1.18a.tar.gz
cd lcms-1.18
make clean
./configure
make
sudo make install
cd ..

curl -O http://ghostscript.com/releases/ghostscript-8.70.tar.gz
tar zxvf ghostscript-8.70.tar.gz
cd ghostscript-8.70
./configure  --prefix=/usr/local
make
sudo make install
cd ..

curl -O http://heanet.dl.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz
tar zxvf ghostscript-fonts-std-8.11.tar.gz
sudo mv fonts /usr/local/share/ghostscript

curl -O ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.5.4-10.tar.gz
tar xzvf ImageMagick-6.5.4-10.tar.gz
cd ImageMagick-6.5.4-10
export CPPFLAGS=-I/usr/local/include
export LDFLAGS=-L/usr/local/lib
./configure --prefix=/usr/local --disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8 --with-gs-font-dir=/usr/local/share/ghostscript/fonts
make
sudo make install
cd ..