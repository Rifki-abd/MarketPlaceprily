{ pkgs }:

{
  channel = "stable-24.05";
  packages = [
    pkgs.flutter
    pkgs.git
    pkgs.openssh
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
