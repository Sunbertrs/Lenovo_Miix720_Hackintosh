# Lenovo_Miix720_Hackintosh

New Opencore EFI maintaining for Lenovo Miix 720.

[The another repository on Github](https://github.com/jennie26/Lenovo-Miix-720-Hackintosh) had stopped its maintenance with an older Opencore 0.6.2 version.

However, this repository now provides newer support for the Lenovo Miix 720. But there are some differences between the two, my level of completion may not be high as the older one. (Although I can't boot its EFI on my device)

Current Opencore version: `1.0.0`

## Specs

|Category|Details|
|--------|-------|
|CPU     |Intel Core i5-7200u (Kaby Lake-R)|
|GPU     |Intel HD Graphics 620|
|Memory  |Dual 4G, total 8G DDR4|
|Network adapter|Intel Dual Band Wireless-AC 8265|
|Audio decoder|Realtek ALC236|
|BIOS version|3SEC71WW|
|Display |12.2’ 2880*1920|
|Storage |Western Digital Black Disk SN720<br>(But it's ok for Eaget SSD Device 512GB, what I'm using now)|
|Touchpad|Idk because my lid is unusable lol|

## Validated macOS version

- [ ] Ventura 13.6.9

- [x] Big Sur 11.7.10

- [x] Catalina 10.15.7

## Necessary adjustments

- Change the model information at `PlatformInfo` -> `Generic`.

- Original network adapter on this device is AC-8265, if you replace it, you would required to adjust the kexts, etc.

- Required to download the latest [HeliPort](https://github.com/OpenIntelWireless/HeliPort/releases) for Wi-Fi connecting because I use `itlwm` kext here.
  - This also means that you can't use the online installer as [Dortania's guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/windows-install.html) uses. Please use a full installer instead.
  - For stability reasons according to documents in Itlwm, I using `itlwm.kext` here rather than `AirportItlwm`. But you can still replace it with the airport one for native network support. Then you can try the online installer.

## Known issues / Todo

- [ ] Backlight issue
  - May encounter a black screen when entering macOS. This can be solved by close then open the lid.

- [ ] MicroSD card (TF card) slot support

- [ ] Would be great if touchscreen supports

- [ ] Battery level issue
  - It doesn't show the battery status.
  
- [ ] Storage drive issue
  - Everything goes well but it stucks at `AppleIntelLpassI2CController` and `IOKit Daemon (kernelmanagerd) stall[] (60s): 'IOUSBHostDevice' (a,20000001)` for some time after updating to Ventura.
  - Also stucks at `syncing disks... Killing all processes` for some time when shutting down.
  - My boot USB-disk can't be recognized, and all the available partitions in internal disk will show twice in Finder sidebar.
