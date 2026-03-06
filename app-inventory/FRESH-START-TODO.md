# QQ's Fresh Start Plan

📅 Last Updated: 2026-02-25
⚠️ Important: Dual-boot with native Ubuntu + WSL

---

## 🔒 Critical Pre-Wipe Rules

1. **WSL will be wiped too** - It's broken, so we'll reinstall fresh after Windows reset (no backup needed)
2. **Keep personal files** during Windows reset
3. **Browsers only**: Thorium + 夸克 (NO Chrome/Firefox!)
4. **Windows reset will break GRUB** - Have Ubuntu live USB ready

---

## 📋 Phase 0: Pre-Wipe Backup Checklist

Do **ALL** of these BEFORE touching Windows reset:

- [ ] **WSL Wipe** (No backup needed - it's broken)
  
  - [x] List WSL distros: `wsl --list --verbose`
  - [ ] Unregister WSL: `wsl --unregister Ubuntu`
  - [ ] (Optional) WSL full shutdown: `wsl --shutdown`

- [ ] **Native Ubuntu Backup**
  
  - [ ] Backup `/home/` directory
  - [ ] Backup SSH keys, git configs, app configs

- [ ] **Windows Files Backup**
  
  - [ ] Documents, Pictures, etc.
  - [ ] App-specific configs to keep

---

## 💥 Phase 1: Windows Reset

- [ ] Go to Settings > Recovery > Reset PC
- [ ] Choose "Keep personal files"
- [ ] Wait for reset to complete

---

## 🔧 Phase 2: GRUB Repair (If Dual-Boot Broken)

1. Boot from Ubuntu live USB

2. Choose "Try Ubuntu without installing"

3. Open terminal and run:
   
   ```bash
   sudo fdisk -l  # Find Ubuntu (e.g., /dev/sda2) and EFI (e.g., /dev/sda1) partitions
   sudo mount /dev/sdXY /mnt  # Replace XY with Ubuntu partition
   sudo mount /dev/sdXZ /mnt/boot/efi  # Replace XZ with EFI partition
   for i in /dev /dev/pts /proc /sys; do sudo mount -B $i /mnt$i; done
   sudo chroot /mnt
   grub-install /dev/sdX  # Replace X with disk (e.g., /dev/sda)
   update-grub
   exit
   for i in /sys /proc /dev/pts /dev; do sudo umount /mnt$i; done
   sudo umount /mnt/boot/efi
   sudo umount /mnt
   ```

4. Reboot - GRUB should be back!

---

## 🚀 Phase 3: Post-Wipe Setup & App Install

### Step 3.1: Fresh WSL Install

- [ ] Install WSL: `wsl --install` (run as Admin, restart if needed)
- [ ] Set up Ubuntu: `wsl --install -d Ubuntu`
- [ ] Verify WSL: `wsl -d Ubuntu`

### Step 3.2: App Installation Sequence

Install in this order for best results:

---

#### 1. System Utilities & Runtimes

- [ ] Clash Verge - `winget install ClashVergeRev.ClashVergeRev`
- [ ] Ubuntu (WSL) - `winget install Canonical.Ubuntu`
- [ ] Windows Subsystem for Linux - `winget install Microsoft.WSL`
- [ ] PowerShell 7-x64 - `winget install Microsoft.PowerShell`
- [ ] Microsoft PowerToys (Preview) - `winget install Microsoft.PowerToys`
- [ ] DirectX - `winget install Microsoft.DirectX`
- [ ] Microsoft GameInput - `winget install Microsoft.GameInput`
- [ ] nodejs + npm
- [ ] Microsoft Windows Desktop Runtime 6 - `winget install Microsoft.DotNet.DesktopRuntime.6`
- [ ] Microsoft Windows Desktop Runtime 8 - `winget install Microsoft.DotNet.DesktopRuntime.8`
- [ ] Microsoft .NET SDK 10 - `winget install Microsoft.DotNet.SDK.10`

---

#### 2. Package Managers & Core Tools

- [ ] 7-Zip (x64) - `winget install 7zip.7zip`
- [ ] Git - `winget install Git.Git`
- [ ] GitHub CLI - `winget install GitHub.cli`
- [ ] Everything (x64) - **Manual**
- [ ] BCUninstaller - `winget install Klocman.BulkCrapUninstaller`
- [ ] Raspberry Pi Imager - `winget install RaspberryPiFoundation.RaspberryPiImager`
- [ ] Rufus - **Manual**

---

#### 3. Development Tools & IDEs

- [ ] Python Install Manager - `winget install PythonSoftwareFoundation.PythonManager` (msstore)
  - [ ] Python 3.14.3 (install via Python Install Manager)
- [ ] Pandoc - `winget install JohnMacFarlane.Pandoc`
- [ ] JetBrains Toolbox - `winget install JetBrains.Toolbox`
  - [ ] PyCharm (install via JetBrains Toolbox)
  - [ ] CLion (install via JetBrains Toolbox)
- [ ] Visual Studio Code (User) - `winget install Microsoft.VisualStudioCode`
- [ ] Pulsar - `winget install Pulsar-Edit.Pulsar`
- [ ] Microsoft Visual Studio Installer - `winget install XPDCFJDKLZJLP8` (msstore)
  - [ ] Microsoft Visual Studio Community 2026 - `winget install Microsoft.VisualStudio.Community`
- [ ] Dev-C++ 5.11 - `winget install Orwell.Dev-C++`
- [ ] Arduino IDE 2.3.7 - **Manual**
- [ ] Arduino 1.8.19 - **Manual**
- [ ] Intel® oneAPI Base Toolkit - `winget install Intel.OneAPI.BaseToolkit`
- [ ] Unity Hub - `winget install Unity.UnityHub`
  - [ ] Unity Editor (install via Unity Hub)
- [ ] Java(TM) SE Development Kit 24 - `winget install Oracle.JDK.24`
- [ ] MSYS2 - `winget install MSYS2.MSYS2`
- [ ] Ollama - `winget install Ollama.Ollama`
- [ ] 天问Block 版本 2025 夏季正式版 SP1 - **Manual**
- [ ] Mind+ - `winget install DFRobot.Mind+`
- [ ] Mixly

---

#### 4. Productivity & Tools

- [ ] MarkText - `winget install MarkText.MarkText`
- [ ] Blender - `winget install BlenderFoundation.Blender`
- [ ] TurboWarp - **Manual** (MSIX only)

---

#### 5. Browsers (NO Chrome/Firefox!)

- [ ] Thorium - `winget install Alex313031.Thorium.AVX2`
- [ ] 夸克 (Quark) - `winget install Alibaba.Quark`

---

#### 6. Media & Communication

- [ ] 哔哩哔哩 (Bilibili) - `winget install Bilibili.Bilibili`
- [ ] ClassIn - `winget install EEO.ClassIn`
- [ ] Discord - `winget install Discord.Discord`
- [ ] Microsoft Teams - `winget install Microsoft.Teams`
- [ ] 腾讯会议 (Tencent Meeting) - `winget install Tencent.TencentMeeting`
- [ ] 微信 (WeChat) - `winget install Tencent.WeChat.Universal`
- [ ] 百度网盘 (Baidu Netdisk) - `winget install Baidu.BaiduNetdisk`
- [ ] 网易云音乐 (NetEase Cloud Music) - `winget install NetEase.CloudMusic`
- [ ] 网易有道翻译 (NetEase Youdao Translate) - `winget install Youdao.YoudaoTranslate`
- [ ] Yuanbao - `winget install Tencent.Yuanbao`

---

#### 7. Gaming & Fun

- [ ] Minecraft for Windows - **Manual**
- [ ] Minecraft Launcher - **Manual**
- [ ] Minecraft: Java Edition - **Manual**
- [ ] Chess - Play & Learn - **Manual**
- [ ] Slow Roads - **Manual**
- [ ] lichess.org - **Manual**
- [ ] Play Free Sudoku online - **Manual**

---

### Step 3.3: Restore Files

- [ ] Restore Windows backups (Documents, Pictures, SSH keys, git configs, etc.)

---

## 🔑 Phase 4: Account Login Checklist

After installing apps, log into these accounts:

- [ ] Google account on Thorium
- [ ] Microsoft Account (for Visual Studio, Store, etc.)
- [ ] 夸克 browser profile

**Communication:**

- [ ] Discord

- [ ] Microsoft Teams

- [ ] 腾讯会议

- [ ] 微信

- [ ] ClassIn

**Media & Cloud:**

- [ ] 哔哩哔哩
- [ ] 百度网盘
- [ ] 网易云音乐
- [ ] 网易有道翻译
- [ ] Yuanbao

**Development:**

- [ ] GitHub (Git/GitHub CLI/VS Code)
- [ ] JetBrains Toolbox
- [ ] Unity Hub

**Gaming:**

- [ ] Minecraft accounts
- [ ] lichess.org & chess.com

**Other:**

- [ ] Clash Verge subscription
- [ ] Any other app-specific logins

---

## ✅ Final Checks

- [ ] All key apps working
- [ ] Dual-boot still works (Ubuntu + Windows)
- [ ] WSL fully restored
- [ ] Only Thorium + 夸克 browsers installed (NO Chrome/Firefox!)
- [ ] Backed-up files restored correctly
- [ ] All accounts logged in

---

## 💡 Quick Reminder

**Chris Titus Tech's Windows Utility** (run after fresh install):

```powershell
irm "https://christitus.com/win" | iex
```
