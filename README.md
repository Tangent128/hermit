hermit
======

Hermit is a couple of sh and awk scripts that form a sort of shell profile "package manager".

It is intended to provide an easy way to apply and remove customizations to .bashrc, .zshrc, etc, such as prompts, aliases, or shell functions.

Current usage is still rather primitive, though; it is necessary to clone this repository into a ~/.hermit/ directory.

Usage
--

To add a patch to your profile:

```bash
~/.hermit/hermit.sh -S patchName
```

To remove a patch:

```bash
~/.hermit/hermit.sh -D patchName
```

(-S and -D are inspired by Arch's pacman due to personal familiarity)

Current patches
--
* `charLookup`: tool to search for unicode characters by keyword (database is very small right now though)
* `prompt-alternia`: a Homestuck-troll-themed shell prompt. Only applies to zsh.

Notes
--

* Patches are stored in ~/.hermit/patches; just specify the patch name, not the filesystem path

Todo
--

* copy patches and files used by patches to ~/.hermit on install regardless of where repository is checked out
* ability to load files via HTTP with curl/wget, thus only needing hermit.sh instead of a full git checkout
