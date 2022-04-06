{
  description = "This is a nix with flake package/and environment to play with AWS EC2";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
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
          ];

          shellHook = ''
            export TMPDIR=/tmp

          '';
        };
      });
}
