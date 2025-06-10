{
  description = "";
  # Each flake is just a set of inputs, a set of outputs and an optional description. The inputs in this basic example will be Nix, home-manager, and snowfall. 
  inputs = {
    # NixPkgs (nixos-24.05)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # NixPkgs Unstable (nixos-unstable)
    #unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    ### Additional Inputs ###


    # Home Manager (release-24.05)
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Lib
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

 };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
        options = import ./lib/options.nix;
        snowfall = {
          meta = {
            name = "homelab";
            title = "NixOS config called homelab";
          };
          namespace = "homelab";
        };
      };

    in
    lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };


   };
}
