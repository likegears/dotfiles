param(
  [string]$WslDistro = $env:WEZTERM_WSL_DISTRO,
  [string]$WslUser = "",
  [switch]$SkipWindows,
  [switch]$SkipWsl
)

$ErrorActionPreference = "Stop"

function Invoke-Wsl {
  param(
    [string]$Distro,
    [string]$User,
    [string]$Script
  )

  $args = @("-d", $Distro)
  if ($User) {
    $args += @("-u", $User)
  }
  $args += @("--", "sh", "-lc", $Script)
  & wsl.exe @args
  if ($LASTEXITCODE -ne 0) {
    throw "WSL command failed for distro '$Distro'."
  }
}

if (-not $SkipWindows) {
  & chezmoi update
  if ($LASTEXITCODE -ne 0) {
    throw "Windows chezmoi update failed."
  }
}

if ($SkipWsl) {
  exit 0
}

$distrosOutput = (& wsl.exe -l -q | Out-String) -replace "`0", ""
$distros = @(
  $distrosOutput -split "[\r\n]+" |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }
)
if (-not $distros.Count) {
  Write-Host "No WSL distro found; Windows sync is complete."
  exit 0
}

if (-not $WslDistro) {
  if ($distros.Count -eq 1) {
    $WslDistro = $distros[0]
  } else {
    throw "Multiple WSL distros found. Set WEZTERM_WSL_DISTRO or pass -WslDistro."
  }
}

if (-not ($distros -contains $WslDistro)) {
  throw "WSL distro '$WslDistro' was not found."
}

$resolvedUser = if ($WslUser) {
  $WslUser
} else {
  (& wsl.exe -d $WslDistro -- sh -lc "whoami").Trim()
}

if (-not $resolvedUser) {
  throw "Could not determine the WSL user for '$WslDistro'."
}

if ($resolvedUser -eq "root") {
  throw "WSL distro '$WslDistro' still defaults to root. Create a normal user first, then rerun sync-dotfiles.ps1."
}

$interopBootstrap = @'
set -eu
if [ ! -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  mkdir -p /etc/binfmt.d
  if [ ! -e /etc/binfmt.d/README ]; then
    printf '%s\n' 'Keep this directory non-empty so WSL can register WSLInterop via systemd-binfmt.' >/etc/binfmt.d/README
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart systemd-binfmt
  fi
fi

if [ ! -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  echo "WSL interop is unavailable. Check /etc/wsl.conf and restart the distro." >&2
  exit 1
fi
'@
Invoke-Wsl -Distro $WslDistro -User "root" -Script $interopBootstrap

$windowsToolsBootstrap = @'
set -eu
mkdir -p "$HOME/.local/bin"

if ! command -v op >/dev/null 2>&1 && command -v op.exe >/dev/null 2>&1; then
  cat >"$HOME/.local/bin/op" <<'EOF'
#!/bin/sh
exec op.exe "$@"
EOF
  chmod +x "$HOME/.local/bin/op"
fi

if ! command -v tailscale >/dev/null 2>&1 && command -v tailscale.exe >/dev/null 2>&1; then
  cat >"$HOME/.local/bin/tailscale" <<'EOF'
#!/bin/sh
exec tailscale.exe "$@"
EOF
  chmod +x "$HOME/.local/bin/tailscale"
fi
'@
Invoke-Wsl -Distro $WslDistro -User $resolvedUser -Script $windowsToolsBootstrap

$preflight = @'
set -eu
command -v git >/dev/null 2>&1 || { echo "git is required in WSL" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required in WSL" >&2; exit 1; }
command -v op >/dev/null 2>&1 || { echo "1Password CLI (op) is required in WSL" >&2; exit 1; }
'@
Invoke-Wsl -Distro $WslDistro -User $resolvedUser -Script $preflight

$syncScript = @'
set -eu
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi update
else
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply likegears
fi
'@
Invoke-Wsl -Distro $WslDistro -User $resolvedUser -Script $syncScript

Write-Host "Windows host and WSL distro '$WslDistro' are in sync."
