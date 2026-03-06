# QQ's Winget Installation Sequence (Complete with IDs)

Generated: 2026-02-24

---

## ⚠️ Important Decisions

- **Browsers**: Thorium + 夸克 (Quark) are both included (revised from "Thorium only")
- **Dual-boot**: Keep native Ubuntu + WSL (backup both first!)

---

## Installation Order Guide

Install in this order for best results:

1. System Utilities & Runtimes (foundational stuff)
2. Package Managers & Core Tools
3. Development Tools & IDEs
4. Productivity & Tools
5. Browsers
6. Media & Communication
7. Gaming & Fun
8. Manual Installation (apps without winget IDs)

---

## Phase 1: System Utilities & Runtimes (Install First!)

### Core System

- [ ] Clash Verge 2.4.6 - ClashVergeRev.ClashVergeRev
- [ ] Ubuntu (WSL) - Canonical.Ubuntu
- [ ] Windows Subsystem for Linux - Microsoft.WSL
- [ ] PowerShell 7-x64 - Microsoft.PowerShell
- [ ] Microsoft PowerToys (Preview) - Microsoft.PowerToys
- [ ] DirectX - Microsoft.DirectX
- [ ] Microsoft GameInput - Microsoft.GameInput

### Visual C++ Redistributables

- [ ] Microsoft Visual C++ 2010 x64 - Microsoft.VCRedist.2010.x64
- [ ] Microsoft Visual C++ 2010 x86 - Microsoft.VCRedist.2010.x86
- [ ] Microsoft Visual C++ 2015+ x64 - Microsoft.VCRedist.2015+.x64
- [ ] Microsoft Visual C++ 2015+ x86 - Microsoft.VCRedist.2015+.x86
- [ ] Microsoft Visual C++ 2015 UWP Desktop - Microsoft.VCLibs.Desktop.14

### .NET Runtimes & SDKs

- [ ] Microsoft Windows Desktop Runtime 6 - Microsoft.DotNet.DesktopRuntime.6
- [ ] Microsoft Windows Desktop Runtime 8 - Microsoft.DotNet.DesktopRuntime.8
- [ ] Microsoft .NET SDK 10 - Microsoft.DotNet.SDK.10

---

## Phase 2: Package Managers & Core Tools

- [ ] 7-Zip 26.00 (x64) - 7zip.7zip
- [ ] Git - Git.Git
- [ ] GitHub CLI - GitHub.cli
- [ ] GitHub Desktop - GitHub.GitHubDesktop
- [ ] Everything 1.4.1.1032 (x64) - **Manual** (no winget ID found)
- [ ] BCUninstaller 5.9.0.0 - Klocman.BulkCrapUninstaller
- [ ] Raspberry Pi Imager v2.0.6 - RaspberryPiFoundation.RaspberryPiImager
- [ ] Rufus - **Manual** (no winget ID found)

---

## Phase 3: Development Tools & IDEs

### Core Dev Tools

- [ ] Python Install Manager - PythonSoftwareFoundation.PythonManager (msstore)
  - [ ] Python 3.14.3 (install via Python Install Manager)
- [ ] Pandoc 3.9 - JohnMacFarlane.Pandoc
- [ ] JetBrains Toolbox 3.2.0.0 - JetBrains.Toolbox
  - [ ] PyCharm (install via JetBrains Toolbox)
  - [ ] CLion (install via JetBrains Toolbox)
- [ ] Visual Studio Code (User) - Microsoft.VisualStudioCode
- [ ] Pulsar 1.131.1 - Pulsar-Edit.Pulsar
- [ ] Microsoft Visual Studio Installer - XPDCFJDKLZJLP8 (msstore)
- [ ] Microsoft Visual Studio Community 2026 - Microsoft.VisualStudio.Community
- [ ] Dev-C++ 5.11 - Orwell.Dev-C++

### Specialized Dev Tools

- [ ] Arduino IDE 2.3.7 - **Manual** (or use: ArduinoSA.IDE.2x? Check winget)
- [ ] Arduino 1.8.19 - **Manual** (legacy)
- [ ] Intel® oneAPI Base Toolkit 2025.2 - Intel.OneAPI.BaseToolkit
- [ ] Unity Hub 3.14.4 - Unity.UnityHub
  - [ ] Unity Editor (install via Unity Hub)
- [ ] Java(TM) SE Development Kit 24 - Oracle.JDK.24
- [ ] MSYS2 - MSYS2.MSYS2
- [ ] Ollama 0.16.1 - Ollama.Ollama
- [ ] Docker Desktop 4.61.0 - Docker.DockerDesktop
- [ ] 天问Block 版本 2025 夏季正式版 SP1 - **Manual**
- [ ] Mind+ 2.0.5 - DFRobot.Mind+
- [ ] Mixly 3.0 - **Manual**
- [ ] PCL 2 & PCL CE - **Manual**
- [ ] SIot V2 (DFRobot) - **Manual**

---

## Phase 4: Productivity & Tools

- [ ] MarkText 0.17.1 - MarkText.MarkText
- [ ] Blender 5.0.1 - BlenderFoundation.Blender
- [ ] TurboWarp - **Manual** (MSIX only)

---

## Phase 5: Browsers

- [ ] Thorium 138.0.7204.303 - Alex313031.Thorium.AVX2
- [ ] 夸克 (Quark) 6.4.5.737 - XPFM18N52NBBB9 (msstore)

---

## Phase 6: Media & Communication

- [ ] 哔哩哔哩 (Bilibili) - Bilibili.Bilibili
- [ ] ClassIn 5.4.2.2851 - EEO.ClassIn
- [ ] Discord 1.0.9225 - Discord.Discord
- [ ] Microsoft Teams - Microsoft.Teams
- [ ] 腾讯会议 (Tencent Meeting) - Tencent.TencentMeeting
- [ ] 微信 (WeChat) - Tencent.WeChat.Universal
- [ ] 百度网盘 (Baidu Netdisk) - Baidu.BaiduNetdisk
- [ ] 网易云音乐 (NetEase Cloud Music) - NetEase.CloudMusic
- [ ] 网易有道翻译 (NetEase Youdao Translate) - Youdao.YoudaoTranslate
- [ ] Yuanbao 2.56.0.621 - Tencent.Yuanbao

---

## Phase 7: Gaming & Fun

- [ ] Minecraft for Windows - **Manual** (MSIX only)
- [ ] Minecraft Launcher - **Manual** (MSIX only)
- [ ] Minecraft: Java Edition - **Manual** (MSIX only)
- [ ] Chess - Play & Learn - **Manual**
- [ ] Slow Roads - **Manual**
- [ ] lichess.org - **Manual**
- [ ] Play Free Sudoku online - **Manual**

---

## Notes

- **winget command format**: `winget install <id>`
- **msstore apps**: Use `winget install <msstore-id>` or install via Microsoft Store
- **Manual apps**: Download from official websites or use existing installers
- **Backup first!**: Don't forget to backup WSL, Ubuntu, and Windows files before resetting!
