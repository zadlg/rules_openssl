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

def _archive_impl(ctx: AnalysisContext) -> list[Provider]:
    """Implementation of rule `archive`.

      Args:
        ctx:
          Analysis context.

      Returns:
        A list of providers.
    """
    return [
        DefaultInfo(),
        ArchiveInfo(
            ar = ctx.attrs.http_archive,
            configure_file = ctx.attrs.configure_file,
            version = ctx.attrs.version,
        ),
    ]

archive = rule(
    impl = _archive_impl,
    attrs = {
        "http_archive": attrs.source(doc = """
          Archive returned by `http_archive` rule.
        """),
        "configure_file": attrs.source(doc = """
          Configure file.
        """),
        "version": attrs.string(doc = """
          OpenSSL version.
        """),
    },
)

def _build_url(kwargs: dict, version: str) -> str:
    """Builds the URL.

      If `url` or `urls` is specified in `kwargs`, it will be picked. Otherwise,
      the `url` will be built using the `version` argument.

      Args:
        kwargs:
          Named arguments.
        version:
          OpenSSL version.

      Returns:
        The URL to the source code archive.
    """
    url = kwargs.get("url")
    if url != None:
        kwargs.pop("url")
        return url
    urls = kwargs.get("urls")
    if urls != None:
        if type(urls) != list:
            fail("`urls` is not a list.")
        if len(urls) != 1:
            fail("`urls` must contain exactly one value")
        kwargs.pop("urls")
        return urls[0]
    return "https://github.com/openssl/openssl/releases/download/openssl-{version}/openssl-{version}.tar.gz".format(version = version)

def _strip_prefix(kwargs: dict, version: str) -> str:
    """Builds the `strip_prefix` argument for `http_archive` rule.

      If `strip_prefix` is specified in `kwargs`, it will be picked. Otherwise,
      it will be built using the `version` argument.

      Args:
        kwargs:
          Named arguments.
        version:
          OpenSSL version.

      Returns:
        The value of the `strip_prefix` argument to `http_archive` rule.
    """
    strip_prefix = kwargs.get("strip_prefix")
    if strip_prefix != None:
        kwargs.pop("strip_prefix")
        return strip_prefix
    return "openssl-{version}".format(version = version)

def _build_sub_targets(kwargs: dict, configure_file: str) -> list[str]:
    """Builds the `sub_targets` argument for `http_archive` rule.

      Args:
        kwargs:
          Named arguments.
        configure_file:
          Name of the configure script file.

      Returns:
        The list of subtargets for `http_archive` rule.
    """
    sub_targets = kwargs.get("sub_targets")
    if sub_targets != None:
        if type(sub_targets) != list:
            fail("`sub_targets` must be a list of strings.")
        kwargs.pop("sub_targets")
    else:
        sub_targets = []
    sub_targets.append(configure_file)
    return sub_targets

def openssl_archive(
        name: str,
        version: str,
        configure_file: str = "Configure",
        *kargs,
        **kwargs):
    """Defines an OpenSSL source code archive.

      Args:
        name:
          Target name.
        version:
          OpenSSL version.
    """
    ar_name = "{name}.ar".format(
        name = name,
    )
    url = _build_url(
        kwargs = kwargs,
        version = version,
    )
    strip_prefix = _strip_prefix(
        kwargs = kwargs,
        version = version,
    )
    sub_targets = _build_sub_targets(
        kwargs = kwargs,
        configure_file = configure_file,
    )
    native.http_archive(
        name = ar_name,
        urls = [url],
        strip_prefix = strip_prefix,
        sub_targets = sub_targets,
        *kargs,
        **kwargs
    )
    archive(
        name = name,
        http_archive = ":{ar_name}".format(
            ar_name = ar_name,
        ),
        configure_file = ":{ar_name}[{configure_file}]".format(
            ar_name = ar_name,
            configure_file = configure_file,
        ),
        version = version,
        visibility = kwargs.get("visibility"),
    )
