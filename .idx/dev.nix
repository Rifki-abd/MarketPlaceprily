{ pkgs }:

{
  channel = "stable-24.05";

  packages = [
    pkgs.flutter
    pkgs.git
    pkgs.openssh
    pkgs.cmake
    pkgs.clang
    pkgs.ninja
    pkgs.pkg-config
    pkgs.chromium  # Pengganti Chrome
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
