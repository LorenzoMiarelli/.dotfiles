#!/usr/bin/env python3
"""Generate karabiner/.config/karabiner/karabiner.json (PC-style shortcuts).

Edit the tables below, then run:  python3 scripts/karabiner.py
Karabiner picks up the change automatically (the script also restarts it).

Physical keys (Leopold FC660C / BLE660C, Apple-style caps):
    Ctrl  -> left_control   "PC Ctrl"
    Opt   -> left_option    "Win/Super" (tap = Spotlight)
    Cmd   -> left_command   "Alt"       (Cmd-Tab already is Alt-Tab)
Right Option is left alone: it is AltGr for US International.
"""
import json
import os
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "karabiner", ".config", "karabiner", "karabiner.json")

TERMINALS = [
    r"^com\.mitchellh\.ghostty$",
    r"^com\.apple\.Terminal$",
    r"^com\.googlecode\.iterm2$",
    r"^net\.kovidgoyal\.kitty$",
    r"^org\.alacritty$",
    r"^com\.github\.wez\.wezterm$",
    r"^dev\.warp\.Warp-Stable$",
]
# Remote desktops / VMs receive the real keys (they run Linux/Windows shortcuts)
VMS = [
    r"^com\.microsoft\.rdc\.macos$",
    r"^com\.utmapp\.UTM$",
    r"^com\.parallels\.desktop\.console$",
    r"^com\.vmware\.fusion$",
    r"^org\.virtualbox\.app\.VirtualBoxVM$",
]

# Ctrl+<key> -> Cmd+<key>  (Shift is passed through: Ctrl+Shift+T -> Cmd+Shift+T)
CTRL_TO_CMD = list("abcdfgiklnopqrstuvwxz") + list("1234567890") + [
    "equal_sign", "hyphen", "comma", "slash", "open_bracket", "close_bracket",
]


def unless(apps):
    return [{"type": "frontmost_application_unless", "bundle_identifiers": apps}]


def remap(key, mods, to_key, to_mods, optional=("shift", "caps_lock"), cond=None):
    m = {
        "type": "basic",
        "from": {"key_code": key, "modifiers": {"mandatory": list(mods), "optional": list(optional)}},
        "to": [{"key_code": to_key, "modifiers": list(to_mods)}],
    }
    if not mods:
        del m["from"]["modifiers"]["mandatory"]
    if cond:
        m["conditions"] = cond
    return m


def shell(key, mods, command, cond=None):
    m = {
        "type": "basic",
        "from": {"key_code": key, "modifiers": {"mandatory": list(mods)}},
        "to": [{"shell_command": command}],
    }
    if cond:
        m["conditions"] = cond
    return m


not_term_vm = unless(TERMINALS + VMS)
not_vm = unless(VMS)

rules = [
    {
        # Everywhere (terminals too: Ghostty turns Option into Alt, and macOS would
        # otherwise steal Ctrl+arrows for "move to Space")
        "description": "PC: Ctrl+arrows / Ctrl+Backspace / Ctrl+Delete word editing (not in VMs)",
        "manipulators": [
            remap("left_arrow", ["control"], "left_arrow", ["left_option"], cond=not_vm),
            remap("right_arrow", ["control"], "right_arrow", ["left_option"], cond=not_vm),
            remap("delete_or_backspace", ["control"], "delete_or_backspace", ["left_option"], cond=not_vm),
            remap("delete_forward", ["control"], "delete_forward", ["left_option"], cond=not_vm),
        ],
    },
    {
        "description": "PC: Ctrl+Y redo, Ctrl+F4 close tab (not in terminals, VMs)",
        "manipulators": [
            remap("y", ["control"], "z", ["command", "shift"], optional=["caps_lock"], cond=not_term_vm),
            remap("f4", ["control"], "w", ["command"], cond=not_term_vm),
        ],
    },
    {
        "description": "PC: Ctrl+letter/number -> Cmd (not in terminals, VMs)",
        "manipulators": [remap(k, ["control"], k, ["command"], cond=not_term_vm) for k in CTRL_TO_CMD]
        + [
            {
                "type": "basic",
                "from": {"pointing_button": "button1", "modifiers": {"mandatory": ["control"], "optional": ["shift"]}},
                "to": [{"pointing_button": "button1", "modifiers": ["command"]}],
                "conditions": not_term_vm,
            }
        ],
    },
    {
        "description": "PC: Alt+F4 quits, Ctrl+Shift+Esc force quit",
        "manipulators": [
            remap("f4", ["command"], "q", ["command"], optional=[], cond=not_vm),
            remap("escape", ["control", "shift"], "escape", ["command", "option"], optional=[], cond=not_vm),
        ],
    },
    {
        "description": "PC: Win (left Option) - tap = Spotlight, Win+arrows tiling, Win+E/D/L/Tab/Shift+S",
        "manipulators": [
            # Window tiling (macOS 15+ built-in: Fn+Ctrl+arrows / F / R)
            remap("left_arrow", ["left_option"], "left_arrow", ["fn", "control"], optional=[], cond=not_vm),
            remap("right_arrow", ["left_option"], "right_arrow", ["fn", "control"], optional=[], cond=not_vm),
            remap("up_arrow", ["left_option"], "f", ["fn", "control"], optional=[], cond=not_vm),
            remap("down_arrow", ["left_option"], "r", ["fn", "control"], optional=[], cond=not_vm),
            remap("l", ["left_option"], "q", ["control", "command"], optional=[], cond=not_vm),  # lock
            remap("tab", ["left_option"], "mission_control", [], optional=[], cond=not_vm),
            remap("d", ["left_option"], "f11", [], optional=[], cond=not_vm),  # show desktop
            remap("s", ["left_option", "shift"], "4", ["command", "control", "shift"], optional=[], cond=not_vm),
            shell("e", ["left_option"], "open ~", cond=not_vm),
            # Tap Option alone -> Spotlight; hold -> normal Option
            {
                "type": "basic",
                "from": {"key_code": "left_option", "modifiers": {"optional": ["any"]}},
                "to": [{"key_code": "left_option", "lazy": True}],
                "to_if_alone": [{"key_code": "spacebar", "modifiers": ["command"]}],
                "conditions": not_vm,
            },
        ],
    },
]

config = {
    "global": {"show_in_menu_bar": True},
    "profiles": [
        {
            "name": "Default",
            "selected": True,
            "virtual_hid_keyboard": {"keyboard_type_v2": "ansi"},
            # Modify the mouse too, needed for Ctrl+click -> Cmd+click
            "devices": [
                # BLE660C over Bluetooth reports itself as keyboard + pointing device,
                # which Karabiner skips by default
                {"identifiers": {"is_keyboard": True, "is_pointing_device": True, "device_address": "d1-68-79-0c-c9-bc"}, "ignore": False},
                {"identifiers": {"is_pointing_device": True, "vendor_id": 1133, "product_id": 45108}, "ignore": False},
            ],
            "complex_modifications": {
                "parameters": {"basic.to_if_alone_timeout_milliseconds": 500},
                "rules": rules,
            },
        }
    ],
}

if __name__ == "__main__":
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as f:
        json.dump(config, f, indent=4)
        f.write("\n")
    print(f"wrote {OUT}")
    # Karabiner does not always notice changes through a symlinked dir: restart its agent
    subprocess.run(
        ["launchctl", "kickstart", "-k", f"gui/{os.getuid()}/org.pqrs.service.agent.karabiner_console_user_server"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
