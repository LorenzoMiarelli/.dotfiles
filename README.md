# How to use

## Linux

```bash
git clone https://github.com/LorenzoMiarelli/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

## macOS

```bash
git clone https://github.com/LorenzoMiarelli/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install-macos.sh
```

Then open **Karabiner-Elements** once and grant the driver extension and Input Monitoring permissions.

Without admin rights (no Homebrew) the script still installs starship, zoxide, fzf, zsh plugins
and fonts in your home; tmux, Ghostty and Karabiner need Homebrew/IT.
Machine-specific shell settings (work proxy, PATH, tools) go in `~/.zshrc.local` (not tracked).

On a MacBook, Karabiner swaps **Globe** and **Ctrl** on the built-in keyboard, so the bottom-left
key is Ctrl like on a PC.

- `scripts/karabiner.py` generates `karabiner/.config/karabiner/karabiner.json` (PC-style shortcuts).
  Edit the script, not the JSON, then re-run it.
- `macos/DefaultKeyBinding.dict` makes Home/End work like on Linux/Windows in native text fields.

### Keyboard cheat sheet (Ctrl / Option / Cmd keycaps)

| Keys | Action |
|---|---|
| Ctrl + C/V/X/Z/A/S/F/T/W/N/... | Cmd + same key (not in terminals or VMs) |
| Ctrl + Y | Redo |
| Finder: Ctrl + X, then Ctrl + V | Cut and move files |
| Caps Lock (tap / hold) | Esc / Ctrl |
| Shift + Caps Lock | Real Caps Lock |
| Ctrl + ←/→, Ctrl + Backspace/Del | Word move / delete (terminal too) |
| Home / End (+Shift, +Ctrl) | Line / document start-end |
| Cmd + Tab, Cmd + F4 | App switcher, quit app (Alt+Tab / Alt+F4) |
| Ctrl + Shift + Esc | Force Quit |
| Option (tap) | Spotlight |
| Option + ←/→/↑/↓ | Tile left / right / fill / restore |
| Option + Ctrl + ←/→ or Ctrl + Cmd + ←/→ | Previous / next desktop (Space) |
| Option + E / D / L / Tab | Finder / show desktop / lock / Mission Control |
| Option + Shift + S | Screenshot area to clipboard |
| Terminals: Ctrl + Shift + C/V/T/W/N/F | Copy / paste / tab / close / window / find |
