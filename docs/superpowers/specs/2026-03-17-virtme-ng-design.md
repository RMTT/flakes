# Specification: Packaging virtme-ng

## Overview
Package `virtme-ng` (https://github.com/arighi/virtme-ng) as a Nix derivation for inclusion in the project.

## Technical Approach
- Use `stdenv.mkDerivation` to create a unified Nix package.
- Incorporate `rustPlatform` tools for building the included Rust binary component.
- Integrate Python build requirements for the core application logic.
- Model the structure after existing project patterns (specifically `@packages/aronet/default.nix`).

## Success Criteria
- [ ] Derivation successfully builds.
- [ ] Package includes both Python and Rust components.
- [ ] `virtme-ng` executes successfully in the Nix environment.
- [ ] Follows project conventions (formatting, dependencies).
