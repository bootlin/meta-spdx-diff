SPDX Diff Build Configuration (kas)
===================================

This directory contains a kas build configuration that enables SPDX 3.0
support and integrates the sbom-diff layer into a Yocto / OpenEmbedded
build environment.

----------------------------------------------------------------------
Overview
----------------------------------------------------------------------

The kas configuration `sbom-diff.yml` sets up the following:

- Adds the meta-sbom-diff layer
- Disables the default SPDX 2.2 generation in scarthgap
- Enables SPDX 3.0 generation (with patches backported)
- Inherits the sbom-diff class to generate SPDX diffs automatically
- Enables additional SPDX features:
  * Kernel configuration export
  * PACKAGECONFIG export

A set of patches in `kas/patches/oe-core/spdx3/` backports upstream
SPDX 3.0 fixes and tasks into scarthgap.

----------------------------------------------------------------------
Usage
----------------------------------------------------------------------

1. Clone kas if not already available:

```bash
   $ pip install kas
```

2. Run a kas build with this configuration:

```bash
   $ kas build kas/sbom-diff.yml
```

3. During the build:
   - SPDX 3.0 SBOM files will be generated
   - sbom-diff will run after image creation
   - A diff JSON will be deployed in:
     tmp/deploy/images/<machine>/spdx_diff-<machine>-<timestamp>.json

----------------------------------------------------------------------
Configuration Details
----------------------------------------------------------------------

local_conf_header entries included by this kas file:

sbom:
  - Remove create-spdx (SPDX 2.2) from INHERIT
  - Add create-spdx-3.0 to INHERIT

sbom-diff:
  - Enable SPDX_INCLUDE_KERNEL_CONFIG
  - Enable SPDX_INCLUDE_PACKAGECONFIG

----------------------------------------------------------------------
Patches
----------------------------------------------------------------------

Directory: kas/patches/oe-core/spdx3/

These patches backport SPDX 3.0 support and fixes from upstream master
into scarthgap. They cover:

  0001 ... 0007   SPDX 3.0 classes, tasks, and license helpers
  0008 ... 0009   Kernel configuration, PACKAGECONFIG export and CVE status metadata

The series file defines the order in which these patches are applied.

----------------------------------------------------------------------
Notes
----------------------------------------------------------------------

- The reference SPDX file is provided by the sbom-diff recipe.
- You can override it in local.conf if needed:
    SPDX_REF_FILE = "/path/to/my/reference.spdx.json"
- Results are timestamped but  multiple runs will overwrite older diffs.
