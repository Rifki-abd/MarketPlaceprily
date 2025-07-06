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
    pkgs.gtk3         # ✅ Penting untuk Linux build
    pkgs.chromium     # ✅ Untuk Flutter web
    pkgs.mesa         # ✅ Untuk eglinfo (opsional tapi penting)
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
