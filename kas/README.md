# spdx-diff KAS Configuration

KAS configuration fragment for enabling SPDX 3.0 and automated SBOM comparison.

This file is meant to be composed with your existing KAS build configurations.

## Usage

```bash
# Add to your existing KAS build
kas build board.yml:image.yml:spdx-diff.yml

# Example with meta-spdx-diff-test
kas build layers/meta-spdx-diff-test/kas/image-minimal.yml:spdx-diff.yml
```

## What It Does

- Adds meta-spdx-diff layer
- Enables SPDX 3.0 (disables SPDX 2.2 on Scarthgap)
- Enables kernel config and PACKAGECONFIG export
- Runs spdx-diff automatically after image builds

## Output

```
tmp/deploy/images/${MACHINE}/${IMAGE_NAME}-${TIMESTAMP}.spdx-diff.json
tmp/deploy/images/${MACHINE}/${IMAGE_NAME}.spdx-diff.json  # Symlink to latest
```

## Customization

Override in `local.conf`:
```bash
SPDX_REF_FILE = "https://example.com/my-baseline.spdx.json"
SPDX_DIFF_EXTRA_ARGS = "--summary -v"
```
