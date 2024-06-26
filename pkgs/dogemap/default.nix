{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dogemap";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogemap.git";
  };

  vendorHash = "sha256-7hRezOBcjB2wsx/SwV519wg3Azh+0kHMcAoc9aYPM3A=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Map service for Dogebox";
    homepage = "https://github.com/dogeorg/dogemap";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
