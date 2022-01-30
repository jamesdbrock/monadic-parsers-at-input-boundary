
{ pkgs ? import (builtins.fetchGit {
  # https://github.com/NixOS/nixpkgs/releases/tag/21.05
  url = "https://github.com/nixos/nixpkgs/";
  ref = "refs/tags/21.05";
  rev = "7e9b0dff974c89e070da1ad85713ff3c20b0ca97";
  }) {}
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodejs-14_x
  ];
  shellHook = ''
  '';
  # LC_ALL = "C.UTF-8"; # https://github.com/purescript/spago/issues/507
}
