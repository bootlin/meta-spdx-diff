SPDX_REF_FILE ?= "${DEPLOY_DIR_IMAGE}/reference-sbom.spdx.json"
python do_sbom_diff() {
    """
    Task: Generate a SPDX diff between a new SBOM and a reference SPDX file.
    """
    import subprocess
    import os
    import shutil
    import bb
    from datetime import datetime

    workdir = d.getVar("WORKDIR")
    deploydir = d.getVar("DEPLOY_DIR_IMAGE")
    image_link_name = d.getVar("IMAGE_LINK_NAME")

    # Resolve SPDX files
    new_spdx = d.expand("${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.spdx.json")
    ref_spdx = d.getVar("SPDX_REF_FILE")

    if not ref_spdx or not os.path.exists(ref_spdx):
        bb.fatal("Reference SPDX file not found: %s" % ref_spdx)
    if not os.path.exists(new_spdx):
        bb.fatal("New SPDX file not found: %s" % new_spdx)

    # Generate timestamped diff
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    diff_filename = f"{image_link_name}-{timestamp}.spdx-diff.json"
    work_output = os.path.join(workdir, diff_filename)
    deploy_output = os.path.join(deploydir, diff_filename)

    # Run sbom-diff-tool
    script = os.path.join(d.getVar('STAGING_BINDIR_NATIVE'), 'sbom-diff-tool')
    spdx_cmd = [
        script,
        ref_spdx,
        new_spdx,
        "--ignore-proprietary",
        "--full",
        "--output", work_output,
    ]
    try:
        process = subprocess.Popen(
            spdx_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        for line in process.stdout:
            bb.plain(line.rstrip())
        retcode = process.wait()
        if retcode != 0:
            bb.fatal("SPDX diff tool failed with exit code %d" % retcode)
    except Exception as e:
        bb.fatal("Failed to run SPDX diff tool: %s" % str(e))

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
do_sbom_diff[depends] += "sbom-diff-tool-native:do_populate_sysroot"

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
