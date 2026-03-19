{
  stdenv,
  htms,
  pkgs,
  ...
} @ attrs:
stdenv.mkDerivation {
  pname = "meirisoda.online";
  version = "1.0.0";
  src = ../.;
  nativeBuildInputs = [htms pkgs.nix];

  buildPhase = ''
    runHook preBuild
    ls -al
    htms -i ./src -o ./out -c ./config.nix
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp ./out/* ./out/.* $out
    runHook postInstall
  '';
}
