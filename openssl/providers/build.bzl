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

ConfigureInfo = provider(
    doc = """
    Info about the configuration stage.""",
    fields = {
        # Configure flags. List of `resolved_macro`.
        "flags": provider_field(list),

        # Configure and build directory.
        "dir": provider_field(Artifact),

        # Configure command line.
        "cmd_args": provider_field(cmd_args),
    },
)

BuildInfo = provider(
    doc = """
    Info about the build.""",
    fields = {
        # The archive configured.
        "archive_info": provider_field(ArchiveInfo),

        # The configuration stage.
        "configure_info": provider_field(ConfigureInfo),

        # Install directory.
        "install_dir": provider_field(Artifact),

        # Build and install command line.
        "cmd_args": provider_field(cmd_args),
    },
)
