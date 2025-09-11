SUMMARY = "SPDX JSON diff tool for packages, kernel config, and PACKAGECONFIG"
DESCRIPTION = "Compare SPDX3 JSON files and extract differences for packages, kernel configs, and PACKAGECONFIG entries."
HOMEPAGE = "https://github.com/kamel-bouhara/sbom-diff-tool"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=3b7e96f81f3e5e1d71e1c1a29d3f9c2b"

SRC_URI = " \
    git://github.com/kamel-bouhara/sbom-diff-tool.git;protocol=https;branch=main \
    https://raw.githubusercontent.com/kamel-bouhara/sbom-diff-tool/refs/heads/main/tests/reference-sbom.spdx.json;name=ref-spdx \
"
SRC_URI[sha256sum] = "b215407d17e4e2daeae85d98469084ba6be89db0091a0feeae9d48b622114111"
SRC_URI[ref-spdx.sha256sum] = "5a551fd24309b62c6289657284967cdabac49d635541c3fe949c42e2b27e4ef1"

SRCREV = "68e2db0bb556fcb0b35547cbc5128b6649533c26"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/sbom-diff-tool ${D}${bindir}/sbom-diff-tool

    install -d ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${WORKDIR}/reference-sbom.spdx.json ${DEPLOY_DIR_IMAGE}/
}

FILES:${PN} += " \
    ${bindir}/sbom-diff-tool \
"

BBCLASSEXTEND = "native"
