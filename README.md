# meta-spdx-diff

Yocto layer for comparing SPDX 3.0 SBOMs between builds.

## Features

- Provides `spdx-diff` as a native build tool
- Adds `do_spdx_diff` task to automatically compare SBOMs
- Generates timestamped diff reports with symlink to latest

## Requirements

- Yocto/OpenEmbedded with SPDX 3.0 support (Scarthgap 5.1+)
- For Scarthgap: OE-Core commit [`a172a0e8d5`](https://git.openembedded.org/openembedded-core/commit/?h=scarthgap&id=a172a0e8d5) or later

## Quick Start

1. Add layer to `bblayers.conf`:
```bash
git clone https://github.com/bootlin/meta-spdx-diff layers/meta-spdx-diff
```

2. In your image recipe:
```bash
inherit spdx-diff
```

3. Enable SPDX 3.0 metadata (recommended):
```bash
SPDX_INCLUDE_KERNEL_CONFIG = "1"
SPDX_INCLUDE_PACKAGECONFIG = "1"
```

4. Build:
```bash
bitbake core-image-minimal
```

## Output

Results are deployed to `tmp/deploy/images/${MACHINE}/`:
```
core-image-minimal-qemux86-64-20250123-120000.spdx-diff.json  # Timestamped
core-image-minimal-qemux86-64.spdx-diff.json                   # Symlink to latest
```

Example output:
```
Packages - Added:
    + example: 0.1
    + i2c-tools: 4.3

Packages - Changed:
    ~ openssl: 3.0.13 -> 3.0.14

Kernel Config - Added:
    + CONFIG_SECURITY_SELINUX: y
```

## Custom Reference SBOM

Default reference: `file://reference-sbom.spdx.json`

Override in your recipe:
```bash
# Local file
SPDX_REF_FILE = "file://my-baseline.spdx.json"

# Or remote
SPDX_REF_FILE = "https://example.com/baseline.spdx.json"
SRC_URI[sha256sum] = "..."
```

## Configuration

```bash
# Extra spdx-diff arguments
SPDX_DIFF_EXTRA_ARGS = "--show-packages --summary"

# Verbose output
SPDX_DIFF_EXTRA_ARGS = "-v"
```

## Examples

See [meta-spdx-diff-test](https://github.com/bootlin/meta-spdx-diff-test) for working examples with KAS.

## Links

- Tool: https://github.com/bootlin/spdx-diff
- PyPI: https://pypi.org/project/spdx-diff/
- Issues: https://github.com/bootlin/meta-spdx-diff/issues
