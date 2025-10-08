param(
    [switch]$b,  # Black
    [switch]$g,  # Gray
    [switch]$i   # Image
)

# Path to your image
$imagePath = "C:\Users\<YOUR USER>\Pictures\background.jpg"

# Registry key for desktop background
$key = "HKCU:\Control Panel\Desktop"

if ($b) {
    Set-ItemProperty -Path $key -Name Wallpaper -Value ""
    Set-ItemProperty -Path $key -Name BackgroundColor -Value 0x000000
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
    Write-Host "Desktop background set to black."
}
elseif ($g) {
    Set-ItemProperty -Path $key -Name Wallpaper -Value ""
    Set-ItemProperty -Path $key -Name BackgroundColor -Value 0x202020
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
    Write-Host "Desktop background set to gray."
}
elseif ($i) {
    if (-not (Test-Path $imagePath)) {
        Write-Error "Image not found: $imagePath"
        exit
    }

    Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $imagePath, 3)
    Write-Host "Desktop background set to image: $imagePath"
}
else {
    Write-Host "Please specify one of the options: -b (black), -g (gray), or -i (image)."
}

Write-Host "Done! You may need to minimize the terminal to see the change."

