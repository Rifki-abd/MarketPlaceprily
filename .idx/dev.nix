{ pkgs }:

{
  channel = "stable-24.05";

  packages = with pkgs; [
    flutter
    git
    openssh
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
