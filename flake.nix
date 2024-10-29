{
  description = "mkalias";

  inputs.nixpkgs.url = github:NixOS/nixpkgs;

  outputs = { self, nixpkgs, ... }: let
    version = "1.0.${self.lastModifiedDate}-nix";
  in {
    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage ./default.nix {
        inherit version;
    };

    packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.callPackage ./default.nix {
      inherit version;
    };
  };
}
