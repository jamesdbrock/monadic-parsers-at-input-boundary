
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodejs-14_x
  ];
  shellHook = ''
  '';
  # LC_ALL = "C.UTF-8"; # https://github.com/purescript/spago/issues/507
}
