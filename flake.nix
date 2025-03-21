{
  description = "A Nix flake for running FastAPI in Docker and locally";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python environment with FastAPI and Uvicorn
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          fastapi
          uvicorn
        ]);

        # Docker image definition
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "my-fastapi";
          tag = "latest";

          contents = [
            pythonEnv
            pkgs.dockerTools.caCertificates
          ];

          config = {
            Cmd = [ "${pkgs.python3}/bin/python" "/app/server.py" ];
            ExposedPorts = { "8000/tcp" = {}; };
          };

          extraCommands = ''
            mkdir -p $out/app
            cp ${./server.py} $out/app/server.py
          '';
        };

        # Bash script to build, load, and run the Docker image
        buildAndRunScript = pkgs.writeShellScriptBin "build-and-run" ''
          #!/bin/bash
          set -e

          # Build the Docker image using Nix
          nix build .#dockerImage

          # Load the Docker image into Docker
          docker load < result

          # Run the Docker container
          docker run -d -p 8000:8000 my-fastapi:latest
        '';

        # Bash script to run server.py locally using fastapi dev
        runLocalScript = pkgs.writeShellScriptBin "run-local" ''
          #!/bin/bash
          set -e

          # Run the FastAPI server locally using fastapi dev
          ${pythonEnv}/bin/fastapi dev server.py --host 0.0.0.0 --port 8000
        '';

      in {
        devShell = pkgs.mkShell {
          buildInputs = [ pythonEnv ];
        };
        packages.dockerImage = dockerImage;
        packages.buildAndRunScript = buildAndRunScript;
        packages.runLocalScript = runLocalScript;
        defaultPackage = dockerImage;
      });
}
