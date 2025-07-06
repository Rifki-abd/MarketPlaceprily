{ pkgs }:

{
  channel = "stable-24.05";

  packages = [
    pkgs.flutter
    pkgs.git
    pkgs.openssh
    pkgs.git-filter-repo
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
