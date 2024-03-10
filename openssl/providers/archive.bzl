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

ArchiveInfo = provider(
    doc = """
      An archive containing the source code of OpenSSL.
    """,
    fields = {
        # The actual archive.
        "ar": provider_field(Artifact),

        # The configure file.
        "configure_file": provider_field(Artifact),

        # OpenSSL version.
        "version": provider_field(str),
    },
)
