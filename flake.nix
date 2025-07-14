{
  description = "Claude Squad - Manage multiple AI terminal agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        claude-squad = pkgs.buildGoModule rec {
          pname = "claude-squad";
          version = "0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "smtg-ai";
            repo = "claude-squad";
            rev = "c4578af505bd9e85d477533db0f7fa7a84477d15";
            sha256 = "sha256-CU3cWrcfsoo9LztZF/TQtWhMSzhwYctl54Mu9P+O1Vk=";
          };

          vendorHash = "sha256-BduH6Vu+p5iFe1N5svZRsb9QuFlhf7usBjMsOtRn2nQ=";

          buildInputs = with pkgs; [
            tmux
            gh
          ];

          nativeBuildInputs = with pkgs; [
            makeWrapper
            git
          ];

          checkInputs = with pkgs; [
            git
          ];

          preCheck = ''
            export HOME=$(mktemp -d)
            git config --global user.email "test@example.com"
            git config --global user.name "Test User"
          '';

          postInstall = ''
            wrapProgram $out/bin/claude-squad \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.tmux pkgs.gh ]}
          '';

          meta = with pkgs.lib; {
            description = "Manage multiple AI terminal agents like Claude Code, Aider, Codex, OpenCode, and Amp";
            homepage = "https://github.com/smtg-ai/claude-squad";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.unix;
          };
        };
      in
      {
        packages.default = claude-squad;
        packages.claude-squad = claude-squad;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            tmux
            gh
            claude-squad
          ];
        };

        apps.default = flake-utils.lib.mkApp {
          drv = claude-squad;
          name = "claude-squad";
        };
      });
}