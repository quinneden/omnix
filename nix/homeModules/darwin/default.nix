{
  imports =
    [(import ./starship.nix)]
    ++ [(import ./zsh.nix)]
    ++ [(import ./scripts)]
    ++ [(import ./darwin-gpg-agent.nix)];
}
