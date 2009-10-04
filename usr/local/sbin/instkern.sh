#!/bin/bash
if [ ! -h '/usr/src/linux' ]; then
    echo 'Please set a symlink in /usr/src/linux -> current kernel source'
    exit 1;
fi

KV=$(ls -l /usr/src/linux); KV=${KV##*linux-}
KV_MINOR=${KV##*6.} 
KV_MAJOR=${KV%%.${KV_MINOR}}

if [ ! -d /boot/linux/${KV_MAJOR} ]; then
    echo "/boot/linux/${KV_MAJOR} does not exist, please create"
    exit 1;
fi

echo 'Enter a suffix, to skip press enter.'
read -e SUFFIX

case '/boot/*' in
    *'vmlinuz'*)
    	mv /boot/vmlinuz /boot/vmlinuz.old
    ;;
    *'System.map'*)
        mv /boot/System.map /boot/System.map.old
    ;;
    *'kern.config'*)
	mv /boot/kern.config /boot/kern.config.old
    ;;
esac

echo "Installing into /boot/linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.*"
cp -L /usr/src/linux/arch/x86/boot/bzImage /boot/linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.kern
cp -L /usr/src/linux/System.map /boot/linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.map
cp -L /usr/src/linux/.config /boot/linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.config
echo "Creating a symlink to /boot/System.map /boot/vmlinuz /boot/kern.config"
cd /boot
ln -sf ./linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.kern ./vmlinuz
ln -sf ./linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.map ./System.map
ln -sf ./linux/${KV_MAJOR}/${KV_MINOR}-${SUFFIX}.config ./kern.config
echo "All done :)"
