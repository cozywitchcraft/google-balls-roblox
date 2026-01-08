:: Requires rojo>=7.5.1
:: Windows-only

@echo off

for /d %%d in (%LOCALAPPDATA%\Roblox\Versions\*) do (
    if exist %%d\RobloxStudioBeta.exe (
        copy assets/balls.png %%d\content\textures\balls.png
    )
)

rojo build -p google-balls.rbxm
