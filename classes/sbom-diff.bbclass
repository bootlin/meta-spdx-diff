SPDX_REF_FILE ??= "file://reference-sbom.spdx.json"

SBOM_DIFF_EXTRA_ARGS ?= ""
SBOM_DIFF_EXTRA_ARGS[doc] = "Specify additional arguments passed to sbom-diff (for example, to enable filtering)."

SBOM_DIFF_LOG_WARN ?= "0"
SBOM_DIFF_LOG_WARN[doc] = "If set to '1', the sbom-diff log is emitted as a warning instead of a plain note."

python do_sbom_diff() {
    """
    Task: Generate a SPDX diff between a new SBOM and a reference SPDX file.
    """
    import subprocess
    import os
    import shutil
    import bb
    import bb.fetch2 as fetch2
    from datetime import datetime

    workdir = d.getVar("WORKDIR")
    deploydir = d.getVar("DEPLOY_DIR_IMAGE")
    image_link_name = d.getVar("IMAGE_LINK_NAME")

    # Resolve SPDX files
    new_spdx = d.expand("${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.spdx.json")
    ref_uri = d.getVar("SPDX_REF_FILE")
    ref_spdx = ""

    bb.note("Fetching SPDX: %s" % ref_uri)

    fetcher = fetch2.Fetch([ref_uri], d)
    try:
        fetcher.download()
        ref_spdx = fetcher.localpath(ref_uri)
        bb.note("Fetched reference SPDX: %s" % ref_spdx)
        d.setVar("SPDX_REF_FILE", ref_spdx)

    except Exception as e:
        bb.fatal("Failed to fetch reference SPDX file: %s" % e)

    if not os.path.exists(new_spdx):
        bb.fatal("New SPDX file not found: %s" % new_spdx)

    # Generate timestamped diff
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    diff_filename = f"{image_link_name}-{timestamp}.spdx-diff.json"
    work_output = os.path.join(workdir, diff_filename)
    deploy_output = os.path.join(deploydir, diff_filename)

    # Run sbom-diff
    spdx_cmd = [
        d.expand("${STAGING_BINDIR_NATIVE}/sbom-diff"),
        ref_spdx,
        new_spdx,
        "--ignore-proprietary",
        "--full",
        "--output",
        work_output
    ]

    spdx_cmd.extend(d.getVar("SBOM_DIFF_EXTRA_ARGS").split())

    try:
        bb.note("Running: %s" % spdx_cmd)
        stdout, stderr = bb.process.run(spdx_cmd)
        if stdout:
            if bb.utils.to_boolean(d.getVar("SBOM_DIFF_LOG_WARN")):
                bb.warn(stdout)
            else:
                bb.plain(stdout)
        if stderr:
            bb.plain(stderr)
    except bb.process.ExecutionError as e:
        bb.fatal("SPDX diff tool failed with exit code %s\n%s \n%s" % (e.exitcode, e.stdout, e.stderr))

    # Ensure deploy directory exists
    bb.utils.mkdirhier(deploydir)

    # Copy the timestamped file (not overwriting any existing symlink)
    shutil.copy2(work_output, deploy_output)

    # Update the symlink to latest
    symlink = os.path.join(deploydir, f"{image_link_name}.spdx-diff.json")
    if os.path.islink(symlink) or os.path.exists(symlink):
        os.remove(symlink)

    # symlink points to the timestamped file
    os.symlink(os.path.basename(deploy_output), symlink)

    bb.note("SPDX diff results deployed to: %s" % deploy_output)
    bb.note("Latest diff symlink: %s -> %s" % (symlink, os.path.basename(deploy_output)))
}
addtask do_sbom_diff after do_create_image_sbom_spdx before do_build
do_sbom_diff[depends] += "sbom-diff-native:do_populate_sysroot"
do_sbom_diff[network] = "1"
do_sbom_diff[nostamp] = "1"

python do_clean:append() {
    import glob, os

    deploydir = d.getVar("DEPLOY_DIR_IMAGE")
    if not deploydir:
        return

    # Remove all image-specific SPDX diff files
    for f in glob.glob(os.path.join(deploydir, "*.spdx-diff.json")):
        try:
            os.remove(f)
        except Exception as e:
            bb.warn("Could not remove %s: %s" % (f, e))
}
