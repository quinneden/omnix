{
  imports =
    [(import ./starship.nix)]
    ++ [(import ./zsh.nix)]
    ++ [(import ./darwin-gpg-agent.nix)];
}
