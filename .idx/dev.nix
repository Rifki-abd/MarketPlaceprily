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
    pkgs.gtk3           # ✅ Tambahkan ini
    pkgs.chromium       # ✅ Untuk Flutter Web
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
