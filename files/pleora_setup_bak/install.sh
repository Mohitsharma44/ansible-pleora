#!/bin/bash
# ***************************************************************************************
#     Pleora Technologies Inc. Copyright (c) 2002-2016
# ***************************************************************************************

# Default variables
HOST_ARCH=`uname -m | sed -e 's/i.86/i686/' -e 's/^armv.*/arm/'`
INSTALL_ROOT=/opt/pleora/ebus_sdk/Ubuntu-14.04-x86_64
INSTALL_DIR_OVERWRITE=yes

START_DIR=`dirname $0`
START_DIR=`cd $START_DIR; pwd`
USER_ID=`id -u`
CP_BIN=cp

# Answer YES to all the prompts (including when running the script again, uninstalling and reinstalling)
ANSWER="yes"
ASK="No"

# Create the set_puregev_vars script
if [ "x86_64" = "x86_64" ]; then
  GENICAM_LIB_SUBDIR=Linux64_x64
elif [ "x86_64" = "i686" ]; then
  GENICAM_LIB_SUBDIR=Linux32_i86
elif [ "x86_64" = "arm" ]; then 
  GENICAM_LIB_SUBDIR=Linux32_ARM
elif [ "x86_64" = "ppc" ]; then 
  GENICAM_LIB_SUBDIR=Linux32_PPC  
fi
GENICAM_LIB_DIR=\$GENICAM_ROOT/bin/$GENICAM_LIB_SUBDIR

# auxiliary functions
InstallFiles()
{
    local FLAGS=$1
    local SRC=$2
    local DST=$3

    local FILES=`ls $SRC 2>/dev/null`
    if [ ! "$FILES" = "" ]; then
        $CP_BIN $FLAGS $SRC $DST
    fi
}

# Initial screen
clear
echo "eBUS_SDK 4.1.7.3988 for linux"
echo "  ( Ubuntu-14.04-x86_64 )"
echo "========================================"
echo ""

# Check required priviledge
if [ `whoami` != root ]; then
  echo "You need to run the installer as superuser (root account)."
  exit 1
fi

# Check to put a warning when installing the SDK on a non-native architecture
if [ "x86_64" != $HOST_ARCH ]; then
  echo ""
  echo "WARNING: Installing __PRODUCT_NAME__ on a non-native architecture."
  echo "The current installation package is for the x86_64 architecture, while"
  echo "the current architecture is $HOST_ARCH. This SDK can only be used to"
  echo "cross-compile your applications."
  echo ""
fi

# This section is to remove the old directory of the SDK...
# We take care of moving the licenses...
if [ -d /opt/pleora/ebus_sdk/lib ]; then
  echo -n "An older version of the eBUS SDK has been found. Replace [$INSTALL_DIR_OVERWRITE]? "
  #read ANSWER
  #until [ "$ANSWER" = "yes" -o "$ANSWER" = "no" -o "$ANSWER" = "" ]; do
  #  echo "Please type yes or no."
  #  echo -n "An older version of the eBUS SDK has been found. Replace  [$INSTALL_DIR_OVERWRITE]? "
  #  read ANSWER
  #done
  #if [ ! "$ANSWER" = "" ]; then
  INSTALL_DIR_OVERWRITE=$ANSWER
  #fi
  if [ "$INSTALL_DIR_OVERWRITE" = "yes" ]; then
    if [ -d /opt/pleora/ebus_sdk/licenses ]; then
      if [ -n "$( ls -A /opt/pleora/ebus_sdk/licenses )" ]; then
        mkdir -p $INSTALL_ROOT/licenses  
        mv /opt/pleora/ebus_sdk/licenses $INSTALL_ROOT/licenses
      fi
    else
      if [ -d /opt/pleora/ebus_sdk/license ]; then
        if [ -n "$( ls -A /opt/pleora/ebus_sdk/license )" ]; then
          mkdir -p $INSTALL_ROOT/licenses  
          mv /opt/pleora/ebus_sdk/license $INSTALL_ROOT/licenses
        fi
      fi
    fi
    # Here delete the sub-folder because of the potential existence of a 
    # cross-compiled version of the SDK
    rm -rf /opt/pleora/ebus_sdk/bin
    rm -rf /opt/pleora/ebus_sdk/include
    rm -rf /opt/pleora/ebus_sdk/lib
    rm -rf /opt/pleora/ebus_sdk/licenses
    rm -rf /opt/pleora/ebus_sdk/license
    rm -rf /opt/pleora/ebus_sdk/module
    rm -rf /opt/pleora/ebus_sdk/share
  fi
fi

if [ -d $INSTALL_ROOT ]; then
  # Preserve the licenses if old location
  if [ -d "$INSTALL_ROOT/license" ]; then    
    if [ -n "$( ls -A $INSTALL_ROOT/license )" ]; then
      mv $INSTALL_ROOT/license $INSTALL_ROOT/licenses
    fi
  fi

  # Cleanup the old installation if any
  $INSTALL_ROOT/bin/uninstall.sh

  # Workaround the lact of exit value
  if [ -f "$INSTALL_ROOT/bin/uninstall.sh" ]; then
    echo "Installation aborted."
    exit 1;
  fi
fi

echo ""
echo "Installing software on ${INSTALL_ROOT}."

mkdir -p $INSTALL_ROOT
mkdir -p $INSTALL_ROOT/licenses

if [ ! "`ls $START_DIR/bin/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/bin
  cp -rf $START_DIR/bin/* $INSTALL_ROOT/bin
fi

if [ ! "`ls $START_DIR/share/doc/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/share/doc
  cp -rf $START_DIR/share/doc/* $INSTALL_ROOT/share/doc
fi

if [ ! "`ls $START_DIR/share/doc/sdk/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/share/doc/sdk
  cp -rf $START_DIR/share/doc/sdk/* $INSTALL_ROOT/share/doc/sdk
fi

if [ ! "`ls $START_DIR/module/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/module
  cp -rf $START_DIR/module/* $INSTALL_ROOT/module
fi

if [ ! "`ls $START_DIR/lib/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/lib
  cp -rf $START_DIR/lib/* $INSTALL_ROOT/lib
fi

if [ ! "`ls $START_DIR/lib/modules/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/lib/modules
  cp -rf $START_DIR/lib/modules/* $INSTALL_ROOT/lib/modules
fi

if [ ! "`ls $START_DIR/include/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/include
  cp -rf $START_DIR/include/* $INSTALL_ROOT/include
fi

if [ ! "`ls $START_DIR/share/samples/* 2>/dev/null`" = "" ]; then
  mkdir -p $INSTALL_ROOT/share/samples
  cp -rf $START_DIR/share/samples/* $INSTALL_ROOT/share/samples
fi

if [ "x86_64" = $HOST_ARCH ]; then

    # Fix issue with genicam / libexpat
    if [ "$HOST_ARCH" = "x86_64" ]; then
        LIB="/lib64 /lib64/ /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu/"
    else
        LIB="/lib /lib/"
    fi
    STATUS="not found"
    for LIB_IT in $LIB; do
        LIBEXPAT_0=`find $LIB_IT -name libexpat.so.0 2>/dev/null`
        if [ -z "$LIBEXPAT_0" ]; then
            # We do not have the libexpat.so.0, try to make the symbolic link
            LIBEXPAT_1=`find $LIB_IT -name libexpat.so.1 2>/dev/null`
            if [ ! -z "$LIBEXPAT_1" ]; then
                # We can make a sumbolic link between .so.1 and .so.0 to work around this issue
                LIBEXPAT_FOLDER=`dirname $LIBEXPAT_1`
                pushd $LIBEXPAT_FOLDER >>/dev/null
                ln -s libexpat.so.1 libexpat.so.0  
                popd >>/dev/null
            fi
        fi
        #Verify if the file or the link available
        LIBEXPAT_0=`find $LIB_IT -name libexpat.so.0 2>/dev/null`
        if [ ! -z "$LIBEXPAT_0" ]; then
            STATUS="found"
        fi
    done
    if [ "$STATUS" = "not found" ]; then
        echo ""
        echo "WARNING: The libexpat.so.0 library is required but not found."  
    fi

    # check if we need to add the libraries to be added to the path
    echo ""
    echo -n "Add libraries to the path [yes]? "
    #read ANSWER
    #until [ "$ANSWER" = "yes" -o "$ANSWER" = "no" -o "$ANSWER" = "" ]; do
    #echo "Please type yes or no."
    #echo -n "Add libraries to the path [yes]? "
    #read ANSWER
    #done
    #if [ "$ANSWER" = "" ]; then
    #    ANSWER="yes"
    #fi
    #if [ "$ANSWER" = "yes" ]; then
    pushd $INSTALL_ROOT/bin >>/dev/null
    ./install_libraries.sh --install
    popd >>/dev/null
    #else
    #    echo ""
    #    echo "INFO: This operation can be done later using the following script:"
    #    echo "$INSTALL_ROOT/bin/install_libraries.sh"
    #fi

    # Build the Universal Pro For Ethernet module when installing
    if [ -d $INSTALL_ROOT/module ]; then

        echo ""
        echo -n "Compile eBUS Universal Pro For Ethernet [yes]? "
        #read ANSWER
        #until [ "$ANSWER" = "yes" -o "$ANSWER" = "no" -o "$ANSWER" = "" ]; do
        #echo "Please enter yes or no."
        #echo -n "Compile eBUS Universal Pro For Ethernet [yes]? "
        #read ANSWER
        #done
        #if [ "$ANSWER" = "" ]; then
        #    ANSWER="yes"
        #fi
        #if [ "$ANSWER" = "yes" ]; then
        pushd $INSTALL_ROOT/module >>/dev/null
        bash build.sh 
        popd >>/dev/null 
        #else
        #    echo ""
        #    echo "INFO: This operation can be done later using the following script:"
        #    echo "$INSTALL_ROOT/module/build.sh"
        #fi              
    fi
    
    # Ask to run the rp_filter configuration
    echo ""
    echo "The Linux network stack does not allow the delivery of outbound "
    echo "packets by default."
    echo ""
    echo "For this reason, an interface cannot enumerate devices on a different "
    echo "subnet if not on a default gateway. The installer can run a script "
    echo "to change the default configuration and work around this issue. "
    echo ""
    echo ""
    echo "More information is available at:"
    echo " https://access.redhat.com/knowledge/solutions/53031"
    echo ""
    echo -n "Do you want the installer to run the script [yes]?"
    #read ANSWER
    #until [ "$ANSWER" = "yes" -o "$ANSWER" = "no" -o "$ANSWER" = "" ]; do
    #  echo -n "Do you want the installer to run the script [yes]?"
    #  read ANSWER
    #done
    #if [ "$ANSWER" = "" ]; then
    #    ANSWER="yes"
    #fi
    #if [ "$ANSWER" = "yes" ]; then
    bash $INSTALL_ROOT/bin/set_rp_filter.sh --mode=0
    #else
    #  echo ""
    #  echo "INFO: This operation can be done later using the following script:"
    #  echo "$INSTALL_ROOT/bin/set_rp_filter.sh "
    #  echo ""
    #fi
         
    if [ -f $INSTALL_ROOT/bin/eBUSd ]; then
        echo ""
        echo "The eBUSd daemon must be installed manually when you are:"
        echo " 1) Using a license with a device that is not enabled by Pleora's technology."
        echo " 2) Using a license with the Pleora Video Server API."
        echo " 3) Using USB3 Vision devices."
        echo "Use the following script to manually install the eBUSd daemon:"
        echo "$INSTALL_ROOT/bin/install_daemon.sh "
        echo "after the installation, if required."
        echo ""
    fi

else
    if [ -d $INSTALL_ROOT/module ]; then
        echo ""
        echo "A version of the eBUS Universal Pro For Ethernet for x86_64 is available from this"
        echo "installation. Using the following script, it can be rebuilt to"
		echo "cross-compile against a different kernel version:"
        echo "$INSTALL_ROOT/module/build.sh"
        echo ""
    fi
    
    # Ask to run the rp_filter configuration
    echo ""
    echo "The Linux network stack does not allow the delivery of outbound "
    echo "packets by default."
    echo ""
    echo "For this reason, an interface cannot enumerate devices on a different "
    echo "subnet if not on a default gateway. You can run the script "
    echo "$INSTALL_ROOT/bin/set_rp_filter.sh "
    echo "on your target platform to change the default configuration and work "
    echo "around this issue."
    echo ""
    echo ""    
    echo "More information is available at:"
    echo " https://access.redhat.com/knowledge/solutions/53031"
    echo ""

    if [ -f $INSTALL_ROOT/bin/eBUSd ]; then
        echo ""
        echo "The eBUSd daemon must be installed and run on your target platform when you are:"
        echo " 1) Using a license with third-party devices."
        echo " 2) Using a license with the Pleora Video Server API."
        echo " 3) Using USB3 Vision devices."
        echo "Use the following script to install and run the eBUSd daemon on your target platform:"
        echo "$INSTALL_ROOT/bin/install_daemon.sh "
        echo ""
    fi
fi

> $INSTALL_ROOT/bin/set_puregev_env
cat > $INSTALL_ROOT/bin/set_puregev_env <<__END__
#!/bin/sh

export PUREGEV_ROOT=$INSTALL_ROOT
export GENICAM_ROOT=\$PUREGEV_ROOT/lib/genicam
export GENICAM_ROOT_V2_4=\$GENICAM_ROOT
export GENICAM_LOG_CONFIG=\$GENICAM_ROOT/log/config/DefaultLogging.properties
export GENICAM_LOG_CONFIG_V2_4=\$GENICAM_LOG_CONFIG
if [ "\$HOME" = "/" ]; then
  export GENICAM_CACHE_V2_4=/.config/Pleora/genicam_cache_v2_4
else
  export GENICAM_CACHE_V2_4=\$HOME/.config/Pleora/genicam_cache_v2_4
fi
export GENICAM_CACHE=\$GENICAM_CACHE_V2_4
export GENICAM_LIB_DIR=$GENICAM_LIB_DIR
mkdir -p \$GENICAM_CACHE

if ! echo \${LD_LIBRARY_PATH} | grep -q \${PUREGEV_ROOT}/lib; then
  if [ "\$LD_LIBRARY_PATH" = "" ]; then
    LD_LIBRARY_PATH=\${PUREGEV_ROOT}/lib
  else
    LD_LIBRARY_PATH=\${PUREGEV_ROOT}/lib:\${LD_LIBRARY_PATH}
  fi
fi

if ! echo \${LD_LIBRARY_PATH} | grep -q \${GENICAM_LIB_DIR}; then
  LD_LIBRARY_PATH=\${GENICAM_LIB_DIR}:\${LD_LIBRARY_PATH}
fi

export LD_LIBRARY_PATH

if ! echo \${PATH} | grep -q \${PUREGEV_ROOT}/bin; then
  PATH=\${PUREGEV_ROOT}/bin:\${PATH}
fi

export PATH

unset GENICAM_LIB_DIR

__END__

echo "Install eBUSd"
bash $INSTALL_ROOT/bin/install_daemon.sh

echo "Installed on $INSTALL_ROOT"
echo "Installation complete."
echo ""
echo ""
