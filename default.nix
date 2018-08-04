with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "why-nix-presentation";
  src = ./.;

  buildInputs = with pkgs; [ pandoc ];
  preBuild = "make clean";

  meta.description = "Presentation about why you should know nix";
}
