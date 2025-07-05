{pkgs}: {
  channel = "stable-24.05";
  packages = [
    pkgs.flutter          # <-- Pastikan ini ada
    pkgs.google-chrome    # <-- Dan ini untuk Chrome
  ];
  idx.extensions = [
    "dart-code.flutter"
  ];
  idx.previews = {
    enable = true;
  };
}