{
  description = "rigx build for book-numerical";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAll = f: nixpkgs.lib.genAttrs systems f;
      srcRoot = builtins.path {
        path = ./.;
        name = "source";
        filter = path: type:
          let base = baseNameOf (toString path); in
          !(builtins.elem base [
            ".rigx" "output" ".git" "result"
            "flake.nix" "flake.lock"
          ]);
      };
    in {
      packages = forAll (system:
        let
          pkgs = import nixpkgs { inherit system; };
          src = srcRoot;
        in rec {
          pdf = pkgs.stdenv.mkDerivation {
            pname = "pdf";
            version = "0.1.0";
            inherit src;
            buildInputs = [ pkgs.texliveFull ];
            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              export HOME=$TMPDIR
              export TEXMFVAR=$TMPDIR/texmf-var
              export TEXMFCONFIG=$TMPDIR/texmf-config
              export TEXMFHOME=$TMPDIR/texmf-home

              cd book

              # Multi-pass: undefined cites/refs resolve only after .aux is written, so
              # the first pass is expected to emit errors. Tolerate non-zero exits and
              # rely on the final-pass PDF check to decide success.
              set +e
              pdflatex -interaction=nonstopmode book_numerical.tex
              makeindex book_numerical.idx
              pdflatex -interaction=nonstopmode book_numerical.tex
              pdflatex -interaction=nonstopmode book_numerical.tex
              set -e
              test -s book_numerical.pdf
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp book_numerical.pdf $out/
              runHook postInstall
            '';
          };
        });
    };
}
