{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  localDogeboxdPath ? null,
  localDpanelPath ? null,
  ...
}:

let
  upstream_dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "3ab75acc73b33be1e695018e82e57c85765dd892";
  };

  dogeboxd = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "f66e1bfb61293662c05d13e12239ed7aa726cb68";
  };

  dogeboxdVendorHash = "sha256-222OtaJIhQMMFrSxV2363e0WoiIDZKTzIYYWRjPyjGw=";

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
    make
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
