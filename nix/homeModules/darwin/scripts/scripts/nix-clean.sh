#!/usr/bin/env bash

garbage_collect() {
  if [[ -e /nix/var/nix/gcroots/auto ]]; then
    sudo rm -rf /nix/var/nix/gcroots/auto
  fi
  sudo nix store gc &>/dev/null | tail -n 1
  sudo nix-collect-garbage -d &>/dev/null | tail -n 1
}

garbage_collect && exit 0

