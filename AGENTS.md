# Agent Guidelines

Welcome to the infrastructure and homelab configuration repository. This project manages NixOS and Terrafrom configurations using Nix Flakes, as well as Grafana/Prometheus observability.

## Project Context
- **Core Tooling:** Nix, NixOS, Home Manager, sops-nix, kubectl.
- **Other domains:** Grafana (OSS), Prometheus (PromQL).
- **Structure:**
  - `nixos/`: Contains NixOS machine configurations and modules.
  - `home/`: Contains Home Manager configurations for users (e.g., `mt`).
  - `flake.nix`: The central entry point defining inputs and outputs.
  - `.agents/skills/`: Custom skills for specific workflows (Grafana, PromQL).

## Agent Directives

### 1. Nix & NixOS
- **Always verify options:** Before writing NixOS or Home Manager configurations, use the `nixos_nix` tool to search and verify options and packages. Do not guess option paths as they change.
- **Flake Evaluation:** Ensure any changes to `flake.nix` or `.nix` files are valid Nix code. Suggest evaluating the flake with `nix flake check` or `nix eval` when appropriate.
- **Formatting:** Keep Nix code clean and well-indented. Follow existing patterns.
- **Secrets:** The project uses `sops-nix` for secret management. Never hardcode plaintext secrets into `.nix` files. Do not try to decrypt sops encrypted files; instead, tell the user what needs to be added.

### 2. Testing and Deployment
- **NixOS:** Deployments or checks are performed with `nixos-rebuild build --flake .#<machine_name>` or `nixos-rebuild switch`.
- **macOS/Darwin:** macOS is configured via `home-manager switch --flake .#darwin` along with `brew bundle --global` (and manual config for `rectangle` and `skhd`).
- **Validation:** When fixing configuration errors, prefer small, incremental changes, verifying syntax before committing.

### 3. Skills and Specialization
- **Observability:** When building dashboards or configuring Grafana, use the `dashboarding` and `grafana-oss` skills. When writing or debugging metric queries, use the `promql` skill.
- **Skills Priority:** Always invoke skills if the task even remotely touches their domain.

### 4. Code Philosophy
- **Idiomatic Nix:** Use built-ins, standard libraries (`flake-utils`, `lib`), and composition. Follow the existing module patterns seen in `nixos/default.nix` and `home/default.nix`.
- **Clear Intent:** Write straightforward configurations. Add comments if a particular hardware quirk or specific option override is used.
- **Safety first:** Do not make assumptions about packages. Always verify they exist in `nixpkgs` using the provided tools.


