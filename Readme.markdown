# Warning

While I try to keep this script up to date I recommend looking into [Homebrew](http://mxcl.github.com/homebrew/) for a simpler solution.

# Introduction

This is bash script to install ImageMagick on Leopard/Snow Leopard.

## Configuration

Please have a look at install_im.sh to customize your environment.

## Execution

Please note: before running the script don't forget that there's no going back. The script will attempt to download and install packages from source, and some may have a make uninstall whilst others may not.
In any case it's up to you.

You can run the script as a normal user. It does use sudo at a certain point, so be sure to not leave the installation unattended.
Depending on many factors the sudo command may 'expire' during the execution of the script, so if it asks you again the password don't worry, it's normal.

Alternatively you can run the script as root.

    chmod +x install_im.sh
    sh install_im.sh

## Contribute

If you find that the script uses an outdated version of the requirements or ImageMagick, please modify the script accordingly, test if it can still produce a valid ImageMagick installation and notify me about the changes, thanks.

## Resources

* [iCoreTech Research Labs](http://www.icoretech.org)
* [Github Repository](http://github.com/masterkain/ImageMagick-sl)