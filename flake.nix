{
  description = "pi coding agent, pre-loaded with the pi-game-dev profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { self
    , nixpkgs
    , systems
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.foldl' lib.recursiveUpdate { } (map f (import systems));

      overlay = final: prev: {
        pi-game-dev = final.callPackage ./package.nix {
          profileName = "pi-game-dev";
          configRepo = "https://github.com/M4jor-Tom/pi-game-dev.git";
          dirEnvVar = "PI_GAME_DEV_DIR";
        };
      };
    in
    eachSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages.${system} = {
          default = pkgs.pi-game-dev;
          pi-game-dev = pkgs.pi-game-dev;
        };

        apps.${system} = {
          default = {
            type = "app";
            program = "${pkgs.pi-game-dev}/bin/pi-game-dev";
            meta.description = "pi coding agent running the pi-game-dev profile";
          };
          pi-game-dev = {
            type = "app";
            program = "${pkgs.pi-game-dev}/bin/pi-game-dev";
            meta.description = "pi coding agent running the pi-game-dev profile";
          };
        };

        devShells.${system}.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-fmt ];
        };
      }) // {
      overlays.default = overlay;
    };
}
