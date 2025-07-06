{ pkgs }:

{
  channel = "stable-24.05";

  packages = with pkgs; [
    flutter
    git
    openssh  # ← ini penting agar ssh-keygen bisa dijalankan
  ];

  idx.extensions = [
    "dart-code.flutter"
  ];

  idx.previews.enable = true;
}
