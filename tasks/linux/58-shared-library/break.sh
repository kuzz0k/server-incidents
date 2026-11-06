#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-58
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit vendor-scanner
{ grep -lsF /opt/vendor/lib /etc/ld.so.conf.d/*.conf || true; } | xargs -r rm -f
rm -rf /opt/vendor
ldconfig
mkdir -p /opt/vendor/bin /opt/vendor/lib
# Библиотека вендора: копия системной libzstd с собственным SONAME libvnd.so.1
src=$(ldconfig -p | awk '$1 == "libzstd.so.1" {print $NF; exit}')
[[ -f $src ]] || die "Не нашёл системную libzstd для подготовки задачи"
python3 - "$(readlink -f "$src")" /opt/vendor/lib/libvnd.so.1 <<'EOF'
# Копирует ELF64-библиотеку и меняет ей DT_SONAME (новое имя не длиннее старого)
import struct, sys
src, dst = sys.argv[1], sys.argv[2]
data = bytearray(open(src, "rb").read())
shoff, = struct.unpack_from("<Q", data, 0x28)
shentsize, shnum = struct.unpack_from("<HH", data, 0x3A)
sections = [struct.unpack_from("<IIQQQQIIQQ", data, shoff + i * shentsize) for i in range(shnum)]
dynamic = next(s for s in sections if s[1] == 6)            # SHT_DYNAMIC
dynstr = sections[dynamic[6]]                               # sh_link → .dynstr
for off in range(dynamic[4], dynamic[4] + dynamic[5], 16):
    tag, val = struct.unpack_from("<qQ", data, off)
    if tag == 14:                                           # DT_SONAME
        pos = dynstr[4] + val
        old = data[pos:data.index(0, pos)]
        new = b"libvnd.so.1"
        assert len(new) <= len(old), (old, new)
        data[pos:pos + len(old)] = new + b"\0" * (len(old) - len(new))
        break
else:
    sys.exit("no DT_SONAME")
open(dst, "wb").write(data)
EOF
cat > /opt/vendor/bin/scanner.py <<EOF
#!/usr/bin/env python3
# Vendor scanner: проверка целостности через libvnd + HTTP API
import ctypes, os, runpy
lib = ctypes.CDLL("libvnd.so.1")
print(f"libvnd loaded, engine version {lib.ZSTD_versionNumber()}", flush=True)
os.environ.update(NAME="vendor-scanner", PORT="8058")
runpy.run_path("$WEBAPP", run_name="__main__")
EOF
write_unit vendor-scanner <<'EOF'
[Unit]
Description=Vendor scanner
After=network.target

[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 /opt/vendor/bin/scanner.py
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now vendor-scanner >/dev/null 2>&1 || true
