cask "spacialshell" do
  version "0.4.0"
  sha256 "2652ebcf71be7912aa750ffddc504c743cfb69d7c6e154cbbbe4aa242455fa82"

  url "https://github.com/AskAlice/SpacialShell-MacOS/releases/download/v#{version}/SpacialShell-#{version}.dmg"
  name "SpacialShell"
  desc "Spatial tiling window manager"
  homepage "https://askalice.github.io/SpacialShell-MacOS/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "SpacialShell.app"
  binary "#{appdir}/SpacialShell.app/Contents/MacOS/spacialctl"

  uninstall quit: "sh.emu.SpacialShell"

  zap trash: [
    "~/.config/spacial-shell",
    "~/Library/Application Support/SpacialShell",
    "~/Library/Caches/sh.emu.SpacialShell",
    "~/Library/HTTPStorages/sh.emu.SpacialShell",
    "~/Library/Preferences/sh.emu.SpacialShell.plist",
  ]

  caveats <<~EOS
    SpacialShell runs without a Dock icon and needs the Accessibility permission:
      System Settings > Privacy & Security > Accessibility
    Quitting SpacialShell restores your windows.
  EOS
end
