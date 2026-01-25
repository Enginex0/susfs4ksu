SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
KSU_BIN=/data/adb/ksu/bin/
TMPDIR=/data/adb/ksu/susfs4ksu
SUSFS_VERSION_RAW=$(${SUSFS_BIN} show version)

echo "***************************************"
echo "SUSFS4KSU Module Info"
echo "***************************************"
echo "[-] Binary: ${SUSFS_BIN}"
echo "[-] Version: ${SUSFS_VERSION_RAW}"

# Check for add_sus_kstat_redirect support
if ${SUSFS_BIN} 2>&1 | grep -q "add_sus_kstat_redirect"; then
    echo "[-] add_sus_kstat_redirect: SUPPORTED"
else
    echo "[!] add_sus_kstat_redirect: NOT SUPPORTED"
    echo "[!] Reinstall module to get correct binary"
fi

# Auto-update disabled - cloud binaries may lack add_sus_kstat_redirect
echo "[-] Auto-update: DISABLED (local binary preserved)"