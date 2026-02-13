# SPDX-License-Identifier: MIT

SPDX_REF_FILE ??= "file://reference-sbom.spdx.json"

SPDX_DIFF_EXTRA_ARGS ?= ""
SPDX_DIFF_EXTRA_ARGS[doc] = "Additional arguments passed to spdx-diff (e.g., -v, --show-packages, --summary)"

SPDX_DIFF_DEPLOYDIR = "${WORKDIR}/spdx-diff/image-deploy"

python do_spdx_diff() {
    """
    Task: Generate a SPDX diff between a new SBOM and a reference SPDX file.
    """
    import os
    import bb.fetch2 as fetch2
    from oe.cve_check import update_symlinks

    deploy_dir_img = d.getVar("DEPLOY_DIR_IMAGE")
    deploydir = d.getVar("SPDX_DIFF_DEPLOYDIR")
    image_link_name = d.getVar("IMAGE_LINK_NAME")
    image_name = d.getVar("IMAGE_NAME")

    # New SPDX from image build
    new_spdx = os.path.join(deploy_dir_img, f"{image_link_name}.spdx.json")
    if not os.path.exists(new_spdx):
        bb.fatal("New SPDX file not found: %s" % new_spdx)

    # Fetch reference SPDX
    ref_uri = d.getVar("SPDX_REF_FILE")
    bb.note("Fetching reference SPDX: %s" % ref_uri)

    fetcher = fetch2.Fetch([ref_uri], d)
    try:
        fetcher.download()
        ref_spdx = fetcher.localpath(ref_uri)
    except Exception as e:
        bb.fatal("Failed to fetch reference SPDX: %s" % e)

    # Generate output filenames
    diff_filename = f"{image_name}.spdx-diff.json"
    deploy_output = os.path.join(deploydir, diff_filename)
    symlink_file = os.path.join(deploydir, f"{image_link_name}.spdx-diff.json")

    # Build command
    cmd = [
        d.expand("${STAGING_BINDIR_NATIVE}/spdx-diff"),
        ref_spdx,
        new_spdx,
        "--ignore-proprietary",
        "--full",
        "--output", deploy_output
    ]

    extra_args = d.getVar("SPDX_DIFF_EXTRA_ARGS")
    if extra_args:
        cmd.extend(extra_args.split())

    # Run spdx-diff
    try:
        bb.note("Running: %s" % " ".join(cmd))
        stdout, stderr = bb.process.run(cmd)
        if stdout:
            bb.plain(stdout)
        if stderr:
            bb.plain(stderr)
    except bb.process.ExecutionError as e:
        bb.fatal("%s" % e)

    # Create symlink
    bb.note("SPDX diff: %s" % deploy_output)
    update_symlinks(deploy_output, symlink_file)
}

addtask do_spdx_diff after do_create_image_sbom_spdx before do_build

SSTATETASKS += "do_spdx_diff"
SSTATE_SKIP_CREATION:task-spdx-diff = "1"
do_spdx_diff[cleandirs] = "${SPDX_DIFF_DEPLOYDIR}"
do_spdx_diff[sstate-inputdirs] = "${SPDX_DIFF_DEPLOYDIR}"
do_spdx_diff[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_spdx_diff[depends] += "python3-spdx-diff-native:do_populate_sysroot"
do_spdx_diff[network] = "1"
