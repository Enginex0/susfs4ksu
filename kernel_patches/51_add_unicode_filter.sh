#!/bin/bash
# Unicode Filter Injection Script
# Converted from 51_add_unicode_filter.patch
# Uses sed with exact context matching from the original patch

set -e
KERNEL_ROOT="${1:-.}"
cd "$KERNEL_ROOT" || exit 1

echo "=== Applying Unicode Filter (script-based) ==="

# ============================================================
# fs/namei.c
# ============================================================
FILE="fs/namei.c"
if [ -f "$FILE" ] && ! grep -q "CONFIG_KSU_SUSFS_UNICODE_FILTER" "$FILE"; then
    echo "[+] Patching $FILE"

    # Include: after #include <linux/uaccess.h>
    sed -i '/#include <linux\/uaccess.h>/a\
#ifdef CONFIG_KSU_SUSFS\
#include <linux/susfs.h>\
#endif' "$FILE"

    # do_mkdirat: after "unsigned int lookup_flags = LOOKUP_DIRECTORY;"
    sed -i '/unsigned int lookup_flags = LOOKUP_DIRECTORY;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(pathname)) {\
		return -EPERM;\
	}\
#endif' "$FILE"

    # unlinkat: after "if ((flag & ~AT_REMOVEDIR) != 0)" block
    sed -i '/if ((flag & ~AT_REMOVEDIR) != 0)/,/return -EINVAL;/{
        /return -EINVAL;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(pathname)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"

    # do_symlinkat: after "unsigned int lookup_flags = 0;"
    sed -i '/^static long do_symlinkat/,/unsigned int lookup_flags = 0;/{
        /unsigned int lookup_flags = 0;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(newname)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"

    # do_linkat: after "int error;" (in do_linkat context)
    sed -i '/^static int do_linkat/,/int error;/{
        /int error;$/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(newname)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"

    # renameat2: after opening brace
    sed -i '/^SYSCALL_DEFINE5(renameat2,.*flags)$/,/^{$/{
        /^{$/a\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(oldname) ||\
	    susfs_check_unicode_bypass(newname)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"
fi

# ============================================================
# fs/open.c
# ============================================================
FILE="fs/open.c"
if [ -f "$FILE" ] && ! grep -q "CONFIG_KSU_SUSFS_UNICODE_FILTER" "$FILE"; then
    echo "[+] Patching $FILE"

    # Include: after #include <linux/compat.h>
    sed -i '/#include <linux\/compat.h>/a\
#ifdef CONFIG_KSU_SUSFS\
#include <linux/susfs.h>\
#endif' "$FILE"

    # do_faccessat: after "const struct cred *old_cred = NULL;"
    sed -i '/const struct cred \*old_cred = NULL;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(filename)) {\
		return -EPERM;\
	}\
#endif' "$FILE"

    # do_sys_openat2: after "struct filename *tmp;"
    sed -i '/^static long do_sys_openat2/,/struct filename \*tmp;/{
        /struct filename \*tmp;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(filename)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"
fi

# ============================================================
# fs/stat.c
# ============================================================
FILE="fs/stat.c"
if [ -f "$FILE" ] && ! grep -q "CONFIG_KSU_SUSFS_UNICODE_FILTER" "$FILE"; then
    echo "[+] Patching $FILE"

    # Include: after #include <linux/compat.h>
    sed -i '/#include <linux\/compat.h>/a\
#ifdef CONFIG_KSU_SUSFS\
#include <linux/susfs.h>\
#endif' "$FILE"

    # vfs_statx: after "int error;" (in vfs_statx context)
    sed -i '/^static int vfs_statx/,/int error;/{
        /int error;$/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(filename)) {\
		return -EPERM;\
	}\
#endif
    }' "$FILE"

    # do_readlinkat: after "unsigned int lookup_flags = LOOKUP_EMPTY;"
    sed -i '/unsigned int lookup_flags = LOOKUP_EMPTY;/a\
\
#ifdef CONFIG_KSU_SUSFS_UNICODE_FILTER\
	if (susfs_check_unicode_bypass(pathname)) {\
		return -EPERM;\
	}\
#endif' "$FILE"
fi

echo "=== Unicode Filter Applied ==="
