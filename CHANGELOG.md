# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### ADDED
- Tests (`tests/`, `terraform test`) that plan and apply the module against mocked providers; CI runs them on the lowest and newest supported Google provider.
- CI also runs weekly, and lints with TFLint's Google ruleset.
- Releases are made by CI from the changelog's newest version (`.github/workflows/release.yml`).
- The checks and the release step are aka-org/gcp-infra's shared workflows, called from this repository's.

## 0.2.0
Every addition is optional; a caller written for 0.1.0 plans the same resources with the same values.
### CHANGED
- The Google provider constraint is a range, `>= 6.8, < 8` (was exactly `6.8.0`); validated on 6.8.0 and 7.46.2.
- In `firewall_rules`, `ports`, `source_ranges` and `tags` are optional.
### ADDED
- `subnetworks`: `secondary_ip_ranges`, `private_ip_google_access`.
- `firewall_rules`: `action` (`allow` / `deny`), `priority`, `source_tags`.
- `nat_gateways`: Cloud NAT gateways, each with its Cloud Router; outputs `routers` and `nat_gateways`.
- Every submodule declares the provider it uses.
- CI: `terraform fmt`, `validate` on the lowest and newest supported provider, TFLint, and a check that the README's Inputs and Outputs tables match the code (generated with terraform-docs).
- README: the fields of each list variable, and "Development".

## 0.1.0
### ADDED
- Initial release of the terraform-google-network module.
