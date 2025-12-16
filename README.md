# meta-sbom-diff

This layer integrates the sbom-diff utility into Yocto builds.
It allows you to generate SPDX Software Bill of Materials (SBOM) diffs
between a newly built image and a reference SPDX file.

----------------------------------------------------------------------
Features
----------------------------------------------------------------------

- Provides sbom-diff as a native build-time utility
- Adds a do_sbom_diff BitBake task that:
  * Compares new vs. reference SPDX JSON files
  * Produces a timestamped diff report
  * Deploys results into the image deploy directory

----------------------------------------------------------------------
Requirements
----------------------------------------------------------------------

- Yocto / OpenEmbedded build environment
- This layer included in bblayers.conf
- On Scarthgap:
    - SPDX2.2 have to be disabled
    - SPDX3 backport patches series applied (see `kas/patches/oe-core/spdx3/`)

----------------------------------------------------------------------
Enabling sbom-diff
----------------------------------------------------------------------
To run an SBOM diff between the reference image and modified builds:

1. Clone and include this layer in your bblayers.conf.

```bash
    $ git clone https://github.com/bootlin/sbom-diff.git layers/meta-sbom-diff
```

2. Enable sbom-diff class from your image recipe

```bash
    inherit sbom-diff
```

3. Enable one or all available SPDX3 features below:

```bash
SPDX_INCLUDE_KERNEL_CONFIG = "1"
SPDX_INCLUDE_PACKAGECONFIG = "1"
```

Note: Enabling ignored cve inclusion is currently not compatible with vex export, set:

```bash
    SPDX_INCLUDE_VEX="none"
```

4. Build your target image or any target, see examples provided in [meta-sbom-diff-test](https://github.com/bootlin/meta-sbom-diff-test).

The resulting SPDX diff will be output as below:

```bash
    [INFO] Opening SPDX file: /home/yocto/build/tmp-glibc/deploy/images/qemux86-64/reference-sbom.spdx.json
    [INFO] Found 2357 elements in the SPDX3 document.
    [INFO] Extracted 36 packages, 0 CONFIG_*, and 42 PACKAGECONFIG entries.
    [INFO] Opening SPDX file: /home/yocto/build/tmp-glibc/deploy/images/qemux86-64/core-image-minimal-qemux86-64.rootfs.spdx.json
    [INFO] Found 2408 elements in the SPDX3 document.
    [INFO] Extracted 38 packages, 0 CONFIG_*, and 42 PACKAGECONFIG entries.
    [INFO] Writing diff results to /home/yocto/build/tmp-glibc/work/qemux86_64-oe-linux/core-image-minimal/1.0/core-image-minimal-qemux86-64.rootfs-20250915-080632.spdx-diff.json

    Packages - Added:
     + example: 0.1
     + i2c-tools: 4.3

    Packages - Removed:

    Kernel Config - Added:

    Kernel Config - Removed:

    PACKAGECONFIG - Added:

    PACKAGECONFIG - Removed:
    NOTE: Tasks Summary: Attempted 2397 tasks of which 2385 didn't need to be rerun and all succeeded.
```

An spdx.json will be available in

   build/tmp-glibc/deploy/images/<MACHINE>/<IMAGE>-<MACHINE>-<timestamp>.json

5. Inspect the diff output for added, removed, or changed packages, kernel configs, and package configurations.

----------------------------------------------------------------------
Reference SBOM
----------------------------------------------------------------------

By default, the sbom-diff class sets:

    SPDX_REF_FILE ?= "${DL_DIR}/reference-sbom.spdx.json"

This points to the reference SPDX JSON file fetched via SRC_URI
into the BitBake download directory.

You can override this default from your custom-image.bb recipe.

```bash
   SRC_URI:append = " file://my-reference.spdx.json"
```

Place the file alongside the images recipe directory:

```bash
   meta-mycustom/recipes-core/images/files/my-reference.spdx.json
```

or using remote uri:

```bash
   SRC_URI:append = " https://../my-reference.spdx.json"
   SRC_URI[sha256sum] = " https://../my-reference.spdx.json"
```

2. Build:

```bash
   $ bitbake custom-image.bb
```

The do_sbom_diff task will now use your custom reference SPDX file.

----------------------------------------------------------------------
Support
----------------------------------------------------------------------
For issues or contributions, please open an issue or pull request on GitHub:

https://github.com/bootlin/meta-sbom-diff
