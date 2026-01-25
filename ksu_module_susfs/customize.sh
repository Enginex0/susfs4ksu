DEST_BIN_DIR=/data/adb/ksu/bin

if [ ! -d ${DEST_BIN_DIR} ]; then
	ui_print "'${DEST_BIN_DIR}' not existed, installation aborted."
	rm -rf ${MODPATH}
	exit 1
fi

unzip ${ZIPFILE} -d ${TMPDIR}/susfs

# Use binary with add_sus_kstat_redirect support (required for race-free kstat spoofing)
if [ ${ARCH} = "arm64" ]; then
	cp ${TMPDIR}/susfs/tools/20000/gki/ksu_susfs_arm64 ${DEST_BIN_DIR}/ksu_susfs
else
	echo "Only arm64 is supported!"
	exit 1
fi

chmod 755 ${DEST_BIN_DIR}/ksu_susfs
chmod 644 ${MODPATH}/post-fs-data.sh ${MODPATH}/service.sh ${MODPATH}/uninstall.sh

rm -rf ${MODPATH}/tools
rm ${MODPATH}/customize.sh ${MODPATH}/README.md


