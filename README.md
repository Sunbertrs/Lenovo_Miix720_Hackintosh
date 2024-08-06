# Lenovo_Miix720_Hackintosh

New Opencore EFI maintaining for Lenovo Miix 720.

[The another repository on Github](https://github.com/jennie26/Lenovo-Miix-720-Hackintosh) has stop its maintaining and keeps at Opencore 0.62 version.

Now this repository will continue the support for Lenovo Miix 720. But there's some difference between that, my level of completion may not be high as its, altought I can't boot its EFI on my device.

Current Opencore version: `1.0`

## Specs

|Category|Details|
|--------|-------|
|CPU    |Intel Core i5-7200u (Kaby Lake-R)|
|GPU    |Intel HD Graphics 620|
|Memory |Dual 4G, total 8G DDR4|
|Network adapter|Intel Dual Band Wireless-AC 8265|
|Audio decoder|Realtek ALC236|
|BIOS version|3SEC71WW|
|Display|12.2' 2880*1920|
|Storage|Western Digital Black Disk SN720|
|       |(But it's ok for Eaget SSD Device 512GB what I'm using now)|
|Touchpad|Idk because my coverpad has unusable lol|

## Validated macOS version

[x] Big Sur 11.7.10
[x] Catalina

## What you need to adjust if using

- PlatformInfo -> Generic

- If you are using different network adapter, would required to change your kext.

## Known issue / Todo

[] Backlight issue

- May meet a black screen when entering macOS. Can be solved by cover with coverpad then remove.
     You can display normally by changing the value to `78563412` in `AAPL,ig-platform-id`, but that would lose your brightness adjusting and display in a max brightness.

[] MicroSD card (TF card) slot support

[] Would be great if touchscreen supports.

[] Battery level issue

- It doesn't show battery.