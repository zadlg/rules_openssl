# Copyright 2024 github.com/zadlg
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_openssl//openssl/providers:archive.bzl", "ArchiveInfo")
load("@rules_openssl//openssl/providers:build.bzl", "BuildInfo", "ConfigureInfo")

def _write_configure_script(ctx: AnalysisContext) -> Artifact:
    """Writes the script for configuring OpenSSL.

      Args:
        ctx:
          Analysis context.

      Returns:
        The Artifact corresponding to the configure script.
    """
    return ctx.actions.write(
        "__configure__.sh",
        """#!/usr/bin/env sh
set -e
_configure_dir="$1"
mkdir -p "${_configure_dir}"
shift 1
_configure_file="$1"
shift 1
_install_dir="$(realpath "$1")"
shift 1
_configure_args="$@"
cd "${_configure_dir}"
set -x
"${_configure_file}" \
    --prefix="${_install_dir}" \
    --openssldir="${_install_dir}" ${_configure_args}
""",
        is_executable = True,
    )

def _write_build_script(ctx: AnalysisContext) -> Artifact:
    """Writes the script for building OpenSSL.

      Args:
        ctx:
          Analysis context.

      Returns:
        The Artifact corresponding to the build script.
    """
    return ctx.actions.write(
        "__build_install__.sh",
        """#!/usr/bin/env sh
set -e
_configure_dir="$1"
shift 1
_install_dir="$1"
shift 1
mkdir -p "${_install_dir}"
cd "${_configure_dir}"
make install_sw
""",
        is_executable = True,
    )

def _configure_impl(ctx: AnalysisContext) -> list[Provider]:
    """Implementation of rule `configure`.

      Args:
        ctx:
          Analysis context.

      Returns:
        List of providers.
    """

    archive_info = ctx.attrs.archive[ArchiveInfo]

    configure_dir = ctx.actions.declare_output(
        "configure",
        dir = True,
    )

    install_dir = ctx.actions.declare_output(
        "install",
        dir = True,
    )
    configure_script = _write_configure_script(
        ctx = ctx,
    )
    configure_args = cmd_args([
        configure_dir.as_output(),
        cmd_args(archive_info.configure_file).relative_to(configure_dir),
        cmd_args(install_dir).ignore_artifacts(),
    ] + ctx.attrs.configure_flags)
    configure_args.hidden(archive_info.ar)

    ctx.actions.run(
        configure_args,
        category = "openssl_configure",
        exe = RunInfo(cmd_args(configure_script)),
    )

    build_script = _write_build_script(
        ctx = ctx,
    )

    build_args = cmd_args([
        configure_dir,
        install_dir.as_output(),
        cmd_args(archive_info.ar).hidden(),
    ])

    ctx.actions.run(
        build_args,
        category = "openssl_build",
        exe = RunInfo(cmd_args(build_script)),
    )

    return [
        DefaultInfo(default_outputs = [configure_dir, install_dir]),
        BuildInfo(
            archive_info = archive_info,
            configure_info = ConfigureInfo(
                flags = ctx.attrs.configure_flags,
                dir = configure_dir,
                cmd_args = configure_args,
            ),
            install_dir = install_dir,
            cmd_args = build_args,
        ),
    ]

openssl_build = rule(
    impl = _configure_impl,
    attrs = {
        "archive": attrs.dep(doc = """
            Archive returned by the `openssl_archive` macro.
        """),
        "configure_flags": attrs.list(
            attrs.arg(),
            doc = """
            Configure flags.
        """,
            default = [
                "no-async",
                "no-autoerrinit",
                "no-cmp",
                "no-cms",
                "no-comp",
                "no-ct",
                "no-deprecated",
                "no-dgram",
                "no-dynamic-engine",
                "no-filenames",
                "no-legacy",
                "no-module",
                "no-shared",
                "no-sock",
                "no-ssl-trace",
                "no-ssl",
                "no-dtls",
                "no-md4",
            ],
        ),
    },
)
