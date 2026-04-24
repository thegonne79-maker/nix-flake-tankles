# AGENTS.md

This is a NixOS flake-based system configuration for a Linux desktop machine (Alienware Area 51).

## Project Structure

- `flake.nix` - Flake definition with nixpkgs inputs
- `configuration.nix` - Main system configuration module
- `hardware-configuration.nix` - Auto-generated hardware-specific config (do not edit directly)
- `flake.lock` - Lock file for reproducible flake builds

## Build Commands

### Build the system
```bash
sudo nixos-rebuild switch --flake .#tankles
```

### Build configuration without switching
```bash
sudo nixos-rebuild build --flake .#tankles
```

### Update flake inputs
```bash
nix flake update
```

### Test build (dry run)
```bash
sudo nixos-rebuild dry-run --flake .#tankles
```

### View generated configuration
```bash
nixos-rebuild edit --flake .#tankles
```

### Clean build artifacts
```bash
sudo nixos-rebuild clean --flake .#tankles
```

## Code Style Guidelines

### General Principles

- NixOS modules follow the declarative configuration paradigm
- Prefer functional composition over imperative modifications
- Use attribute sets for grouping related configuration
- Keep configuration organized into logical sections with comments

### File Organization

1. Imports at the top of the file
2. Logical sections separated by blank lines and comments
3. Comment format: `# <section number>. <Description>`
4. Hardware-specific config stays in `hardware-configuration.nix`

### Attribute Set Formatting

- Use 2-space indentation
- Align `=` signs in attribute sets when practical
- Use shorthand attribute set syntax when attributes share common prefix:
  ```nix
  services.pipewire = {
    enable = true;
    alsa.enable = true;
  };
  ```

### Attribute Names

- Use camelCase for NixOS option names (`networkmanager.enable`)
- Use descriptive names that match upstream NixOS options
- Section headers use numbered comments: `# 1. Audio`, `# 2. Hardware`

### Imports

- Import hardware config: `imports = [ ./hardware-configuration.nix ];`
- Keep module imports at the top
- Use explicit relative paths for local modules

### Types and Values

- Use proper types (strings, lists, booleans, attribute sets)
- Strings must be quoted: `"en_US.UTF-8"`
- Lists use square brackets: `[ "nvidia" ]`
- Booleans are lowercase: `enable = true`
- Paths use appropriate format (`./configuration.nix`, `"/dev/disk/by-uuid/..."`)

### Working with pkgs

- Access packages via `pkgs.packageName`
- Use `with pkgs;` for multiple packages in environment.systemPackages
- Use `pkgs.linuxPackages_latest` for kernel selection

### Overrides

- Use `override { ... }` for package modifications:
  ```nix
  (mumble.override { pulseSupport = true; })
  ```
- Always parenthesize when calling methods

### Attribute Path Shorthand

When accessing deeply nested attributes repeatedly:
```nix
# Instead of this:
services.xserver.enable = true;
services.desktopManager.plasma6.enable = true;

# Keep it as-is for module declarations (required by NixOS)
```

### Comments

- Use full-line comments (`# comment`) for section headers
- Use inline comments for clarifications when necessary
- Do not comment out dead code; remove it

### Nixpkgs Config

- Allow unfree packages: `nixpkgs.config.allowUnfree = true;`
- Enable experimental features: `nix.settings.experimental-features = [ "nix-command" "flakes" ];`

## Common Patterns

### Enabling a Service
```nix
services.<serviceName> = {
  enable = true;
  # ... additional options
};
```

### Adding User Packages
```nix
environment.systemPackages = with pkgs; [
  package1
  package2
];
```

### Hardware Configuration (NVIDIA Optimus)
```nix
hardware.nvidia.prime = {
  sync.enable = true;
  nvidiaBusId = "PCI:2:0:0";
  intelBusId = "PCI:0:2:0";
};
```

## Validation

### Check Nix syntax
```bash
nix-instantiate --parse flake.nix
```

### Evaluate the configuration
```bash
nix eval .#nixosConfigurations.tankles.config.system.build.toplevel --apply 'x: x'
```

## Notes

- The system uses Plasma 6 as the desktop environment
- NVIDIA PRIME sync is configured for hybrid graphics
- PipeWire replaces PulseAudio for audio
- Hardware config is auto-generated and should not be manually edited