{ pkgs }:

{
  channel = "stable-24.05";

  packages = [
    pkgs.flutter
    pkgs.git
    pkgs.openssh
    pkgs.python311Packages.pip
    pkgs.python311Packages.git-filter-repo
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
