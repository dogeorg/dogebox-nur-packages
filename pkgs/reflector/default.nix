{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "reflector";
  version = "0.0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/reflector.git";
    rev = "dffbb3196eb4ebeabf56ea30af7049f75b8746c6";
  };

  vendorHash = "sha256-Dfdzc2wZWis2/Lla6VLYkSUNKw4dTw8kEGCGdDN0org=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Dogebox Reflector service";
    homepage = "https://github.com/dogeorg/reflector";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
