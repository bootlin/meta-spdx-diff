SUMMARY = "SPDX JSON diff tool for packages, kernel config, and PACKAGECONFIG"
DESCRIPTION = "Compare SPDX3 JSON files and extract differences for packages, kernel configs, and PACKAGECONFIG entries."
HOMEPAGE = "https://github.com/bootlin/sbom-diff"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=a0a1050a465f5d6ca944306c5642dc96"

SRC_URI = " \
    git://github.com/bootlin/sbom-diff.git;protocol=https;branch=main \
"

SRCREV = "e2d3fa13040875fccf3e0cc5747a299e54b3379b"

RDEPENDS:${PN} = "python3-core"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/sbom-diff ${D}${bindir}/sbom-diff
}

FILES:${PN} += " \
    ${bindir}/sbom-diff \
"

BBCLASSEXTEND = "native"
