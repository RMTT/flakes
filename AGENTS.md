# Agent Guidelines

Welcome to the infrastructure and homelab configuration repository. This project manages NixOS and Terrafrom configurations using Nix Flakes, as well as Kubernetes workloads and Grafana/Prometheus observability.

## Project Context
- **Core Tooling:** Nix, NixOS, Home Manager, sops-nix, kubectl.
- **Other domains:** Kubernetes, Grafana (OSS), Prometheus (PromQL).
- **Structure:**
  - `nixos/`: Contains NixOS machine configurations and modules.
  - `home/`: Contains Home Manager configurations for users (e.g., `mt`).
  - `flake.nix`: The central entry point defining inputs and outputs.
  - `.agents/skills/`: Custom skills for specific workflows (Kubernetes, Grafana, PromQL).

## Agent Directives

### 1. Nix & NixOS
- **Always verify options:** Before writing NixOS or Home Manager configurations, use the `nixos_nix` tool to search and verify options and packages. Do not guess option paths as they change.
- **Flake Evaluation:** Ensure any changes to `flake.nix` or `.nix` files are valid Nix code. Suggest evaluating the flake with `nix flake check` or `nix eval` when appropriate.
- **Formatting:** Keep Nix code clean and well-indented. Follow existing patterns.
- **Secrets:** The project uses `sops-nix` for secret management. Never hardcode plaintext secrets into `.nix` files.

### 2. Testing and Deployment
- **NixOS:** Deployments or checks are performed with `nixos-rebuild build --flake .#<machine_name>` or `nixos-rebuild switch`.
- **macOS/Darwin:** macOS is configured via `home-manager switch --flake .#darwin` along with `brew bundle --global` (and manual config for `rectangle` and `skhd`).
- **Validation:** When fixing configuration errors, prefer small, incremental changes, verifying syntax before committing.

### 3. Skills and Specialization
- **Kubernetes:** When dealing with k8s workloads, debugging pods, Helm charts, or manifests, **must** invoke the `kubernetes-specialist` skill.
- **Observability:** When building dashboards or configuring Grafana, use the `dashboarding` and `grafana-oss` skills. When writing or debugging metric queries, use the `promql` skill.
- **Skills Priority:** Always invoke skills if the task even remotely touches their domain.

### 4. Code Philosophy
- **Idiomatic Nix:** Use built-ins, standard libraries (`flake-utils`, `lib`), and composition. Follow the existing module patterns seen in `nixos/default.nix` and `home/default.nix`.
- **Clear Intent:** Write straightforward configurations. Add comments if a particular hardware quirk or specific option override is used.
- **Safety first:** Do not make assumptions about packages. Always verify they exist in `nixpkgs` using the provided tools.

### 5. Kubernetes Services

Tip: When manipulating kubernetes cluster, must get granted from user first. For sensitive data, put it into values.yaml and encryt it with sops.

- **Structure:** The `services/` directory is the root for Kubernetes service definitions. Each subdirectory represents a logical service (e.g., `postgresql/`, `ollama/`).
- **Deployment & Management:** 
  - Use the helper scripts located in `.bin/` for managing service lifecycle (e.g., `service-install`, `service-upgrade`, `service-status`).
  - Always check `lib.sh` for common library functions before writing new deployment scripts.
  - Manifests should follow the constraints in the `kubernetes-specialist` skill.
- **Adding Services:**
  1. Create a subdirectory under `services/`.
  2. Include a `README.md` documenting the service.
  3. Ensure all manifests are properly labeled for observability (Prometheus/Grafana).
