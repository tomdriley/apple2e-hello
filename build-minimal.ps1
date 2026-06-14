# Minimal pipeline: ca65 -> ld65 -> raw disk image -> MAME. No AppleCommander.
# A .dsk is just a flat file: 35 tracks x 16 sectors x 256 bytes = 143,360 bytes.
# The boot ROM only reads track 0 / sector 0 = the first 256 bytes.

Set-Location $PSScriptRoot

ca65 -o hello.o hello.s
if ($LASTEXITCODE -ne 0) { exit 1 }

ld65 -C hello.cfg -o boot.bin hello.o
if ($LASTEXITCODE -ne 0) { exit 1 }

# "dd": boot sector first, zeros for the remaining 559 sectors
$disk = New-Object byte[] (35 * 16 * 256)
$boot = [System.IO.File]::ReadAllBytes("$PSScriptRoot\boot.bin")
[Array]::Copy($boot, 0, $disk, 0, 256)
[System.IO.File]::WriteAllBytes("$PSScriptRoot\hello-minimal.dsk", $disk)

mame apple2e -flop1 "$PSScriptRoot\hello-minimal.dsk" -skip_gameinfo
