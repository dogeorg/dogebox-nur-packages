{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  localDogeboxdPath ? null,
  ...
}:

let
  dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "05b9b3d90a1768cb30e6b8e5e8b9916975344a9d";
  };

  dogeboxd = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "39cd59a7bda8b39ce4bf9916bf1f7503b0945db1";
  };

  dogeboxdVendorHash = "sha256-sCeuZC555CtiZqROfPGPUYsHzejZL5e5ow9IhU60B3I=";

  devPath = builtins.path { path = localDogeboxdPath; };
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = if localDogeboxdPath != null then
    pkgs.runCommandNoCC "dogeboxd-dev-source" { } ''
      mkdir -p $out
      cp -rT ${devPath} $out
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
