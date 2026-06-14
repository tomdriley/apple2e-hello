# Build a self-booting Apple IIe "Hello, World!" disk and run it in MAME.
# Pipeline: ca65 -> ld65 -> AppleCommander (disk image) -> boot sector patch -> MAME

$CA65 = "C:\cc65\bin\ca65.exe"
$LD65 = "C:\cc65\bin\ld65.exe"
$JAVA = "C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot\bin\java.exe"
$AC   = "C:\AppleCommander\AppleCommander-ac-13.0.jar"
$MAME = "C:\mame\mame.exe"

Set-Location $PSScriptRoot

Write-Host "==> Assembling hello.s ..."
& $CA65 -o hello.o hello.s
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> Linking (256-byte boot sector at `$0800) ..."
& $LD65 -C hello.cfg -o boot.bin hello.o
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> Creating 140K DOS 3.3 disk image with AppleCommander ..."
Remove-Item .\hello.dsk -ErrorAction SilentlyContinue
& $JAVA -jar $AC -dos140 hello.dsk HELLO
if ($LASTEXITCODE -ne 0) { exit 1 }

# Also store the program as a catalog file (browsable with AppleCommander -ll)
Get-Content boot.bin -Encoding Byte -Raw | & $JAVA -jar $AC -p hello.dsk HELLO BIN 0x0800
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> Installing boot sector (track 0, sector 0) ..."
$disk = [System.IO.File]::ReadAllBytes("$PSScriptRoot\hello.dsk")
$boot = [System.IO.File]::ReadAllBytes("$PSScriptRoot\boot.bin")
[Array]::Copy($boot, 0, $disk, 0, 256)
[System.IO.File]::WriteAllBytes("$PSScriptRoot\hello.dsk", $disk)

Write-Host "==> Launching MAME ..."
# MAME must run from its own directory so the relative rompath resolves;
# -video bgfx -bgfx_backend d3d11 because D3D9 is unavailable on this machine.
Push-Location (Split-Path $MAME)
& $MAME apple2e -flop1 "$PSScriptRoot\hello.dsk" -skip_gameinfo -video bgfx -bgfx_backend d3d11
Pop-Location
