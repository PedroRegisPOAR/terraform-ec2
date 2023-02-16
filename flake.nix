{
  description = "This is a nix with flake package/and environment to play with AWS EC2";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-kubectl-1-21-3.url = "github:NixOS/nixpkgs/078285c64535f7c9a8f7f550fa80af9d15107553";
  };

  outputs = { self, nixpkgs, nixpkgs-kubectl-1-21-3, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        pkgs-kubectl-1-21-3 = import nixpkgs-kubectl-1-21-3 {
          inherit system;
        };
      in
      {
        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
            bash
            coreutils

            curl
            gnumake

            awscli
            terraform_0_13
            eksctl
            pkgs-kubectl-1-21-3.kubectl
            aws-iam-authenticator
          ];

          shellHook = ''
            export TMPDIR=/tmp
            # export LD_PRELOAD="''${pkgsAllowUnfree.stdenv.cc.cc.lib}/lib":$LD_PRELOAD
            # export LD_LIBRARY_PATH="$(nix build --print-out-paths nixpkgs#stdenv.cc.cc.lib)/lib"
            export LD_LIBRARY_PATH="$(nix build --print-out-paths nixpkgs#glibc)/lib"
#            export LD_LIBRARY_PATH="''${
#              pkgsAllowUnfree.lib.makeLibraryPath
#                (
#                  with pkgsAllowUnfree.pythonManylinuxPackages; [
#                      manylinux1Package manylinux2010Package manylinux2014Package
#                    ]
#                )
#              }":$LD_LIBRARY_PATH
          '';
        };
      });
}
