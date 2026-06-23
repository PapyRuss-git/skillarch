#!/usr/bin/env bash
# VM guest integration for i3/X11: clipboard sharing + dynamic resolution.
# Detects the hypervisor and starts the matching guest agent, once.
# Each branch is guarded, so this is a harmless no-op on bare metal or when
# the agent package is not installed. Started from ~/.config/i3/config.

virt="$(systemd-detect-virt 2>/dev/null || echo none)"

# start GUARD_PROCNAME BINARY [ARGS...]
# Run BINARY in the background if it is installed and not already running.
start() {
    guard="$1"; shift
    command -v "$1" >/dev/null 2>&1 || return 0
    pgrep -x "$guard" >/dev/null 2>&1 && return 0
    "$@" &
}

case "$virt" in
    oracle)    start VBoxClient    VBoxClient-all ;;   # VirtualBox
    kvm|qemu)  start spice-vdagent spice-vdagent  ;;   # QEMU/KVM, GNOME Boxes (SPICE)
    vmware)    start vmtoolsd      vmtoolsd        ;;   # VMware (open-vm-tools)
    *)         : ;;                                    # bare metal / unknown — nothing to do
esac
