{ pkgs }:

{
  channel = "stable-24.05";
  packages = [
    pkgs.flutter
    pkgs.openssh
    pkgs.git
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews = {
    enable = true;
  };
}
