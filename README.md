# cura-build-environment

This is a fork from https://github.com/Ultimaker/cura-build-environment/ and my failed attempt to build the Python environment for Cura (and Cura itself) using MSys2/MinGW64.

You can try it by running `./build.sh` from within this directory using the MSys/MinGW64 environment. Edit the included `INSTALL_DIR` variable as you like.

The current iteration fails at building numpy.

I dropped any further attempts as MSys2 will also "[...] drop active support of Windows 7 and 8.0 sometime during 2022." And Qt6 already did so.

# Motivation

My motivation for this was to be able to run Cura 5.0.0 on Windows 7. This is currently not possible. There are still many PCs out there that can run applications like Cura just fine - performance wise. But missing software support turns those into scrap. This is not very sustainable in my opinion. Therefore, I wanted to give those PCs a little longer life. Unfortunately without success, as my time is also limited.
