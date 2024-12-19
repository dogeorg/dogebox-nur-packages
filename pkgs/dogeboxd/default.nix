{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  dbxRelease ? "",
  nurPackagesHash ? "",
  localDogeboxdPath ? null,
  localDpanelPath ? null,
  ...
}:

let
  upstream_dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "cff324dfe45f63d7ea04eb8c30fed73e83719a1f";
  };

  dogeboxd = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "a5ebe8dff68d22cf027434f8a7c0a8fce4fe5733";
    allRefs = true;
  };

  dogeboxdVendorHash = "sha256-vvrcTHlaCkfm/OicCgwUm101B6TY7E1BgwCzBv73OxM=";

  dogeboxDevPath = builtins.path { path = localDogeboxdPath; };
  dpanelDevPath = builtins.path { path = localDpanelPath; };

  dpanel = if localDpanelPath != null then dpanelDevPath else upstream_dpanel;
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = if localDogeboxdPath != null then
    pkgs.runCommandNoCC "dogeboxd-dev-source" { } ''
      mkdir -p $out
      cp -rT ${dogeboxDevPath} $out
    ''
  else
    dogeboxd;

  vendorHash = if localDogeboxdPath != null then null else dogeboxdVendorHash;

  buildPhase = ''
    DBX_RELEASE=${dbxRelease} DBX_NUR_HASH=${nurPackagesHash} make
  '';

  installPhase = ''
    mkdir -p $out/dogeboxd/bin
    cp build/* $out/dogeboxd/bin/

    mkdir -p $out/dpanel
    cp -r ${dpanel}/. $out/dpanel/
  '';

  doCheck = false;

  nativeBuildInputs = [
    pkgs.go_1_22
  ];

  buildInputs = [
    pkgs.systemd.dev
  ];

  meta = with lib; {
    description = "Dogebox OS system manager service";
    homepage = "https://github.com/dogeorg/dogeboxd";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
