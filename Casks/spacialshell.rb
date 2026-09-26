cask "spacialshell" do
  version "0.2.1"
  sha256 "f0489625e88e3b74260ae9e3dcbad75acaf8f03f10b753f9cf928e0c9cff844d"

  url "https://github.com/AskAlice/SpacialShell-MacOS/releases/download/v#{version}/SpacialShell-#{version}.dmg"
  name "SpacialShell"
  desc "Spatial tiling window manager"
  homepage "https://askalice.github.io/SpacialShell-MacOS/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
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
