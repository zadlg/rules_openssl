# [OpenSSL] toolchain and rules for [Buck2].

This repository implements a [Buck2] toolchain for using [OpenSSL].

It builds [OpenSSL] from source, using by default archives from the
[OpenSSL GitHub release page].

_TL;DR_: See [`openssl_archive`] and [`openssl_build`].

## Dependencies

### `python_bootstrap` and `cxx` toolchains.

`python_bootstrap` and `cxx` toolcains must be enabled.

To do so, users may add the following to their `toolchains` cell:

```starlark
load("@prelude//toolchains:cxx.bzl", "system_cxx_toolchain")
load("@prelude//toolchains:python.bzl", "system_python_bootstrap_toolchain")

system_python_bootstrap_toolchain(
    name = "python_bootstrap",
    visibility = ["PUBLIC"],
)

system_cxx_toolchain(
    name = "cxx",
    visibility = ["PUBLIC"],
)
```

`python_bootstrap` is used by the [`http_archive`] rule.

`cxx` is used to compile [OpenSSL] from source.

### GNU Make

[GNU Make] is also needed, since the [OpenSSL] build stage is using Make.

## Installation

### Adding the cell

In order to start using the rules and the toolchain implemented by this repository,
users first need to clone the repo under their [Buck2] project.

Then, a new cell call `rules_openssl` must be declared in their `.buckconfig` file:

```
# .buckconfig
[repositories]
rules_openssl = rules_openssl/
```

If one wishes to place this repository under another directory than root, the
following can be done:

```
# .buckconfig
[repositories]
rules_openssl = path/to/this/repo/cloned
```

## Building OpenSSL

Two rules have to be used together in order to build [OpenSSL].

### [`openssl_archive`]

First, users must declare a new [OpenSSL] archive. Usually, this archive
comes from the [OpenSSl GitHub release page]:

```starlark
# BUCK
load("@rules_openssl//openssl:rules.bzl", "openssl_archive")

openssl_archive(
    name = "openssl-srcs",
    version = "3.2.1",
    sha256 = "83c7329fe52c850677d75e5d0b0ca245309b97e8ecbcfdc1dfdc4ab9fac35b39",
)
```

In the example above, [`openssl_archive`] determines the URL to the archive
using the `version` argument:

```starlark
    return "https://github.com/openssl/openssl/releases/download/openssl-{version}/openssl-{version}.tar.gz".format(version = version)
```

### [`openssl_build`]

Then, [OpenSSL] can be built from the output of an [`openssl_archive`]:

```starlark
# BUCK
load("@rules_openssl//openssl:rules.bzl", "openssl_build")

openssl_build(
    name = "openssl",
    archive = ":openssl-srcs",
)
```

## License

See [License](LICENSE).

[OpenSSL]: https://openssl.org/
[Buck2]: https://buck2.build/
[OpenSSL GitHub release page]: https://github.com/openssl/openssl/releases
[`http_archive`]: https://buck2.build/docs/api/rules/#http_archive
[GNU Make]: https://www.gnu.org/software/make/
[`openssl_archive`]: docs/root/openssl/rules.bzl.md#openssl_archive
[`openssl_build`]: docs/root/openssl/rules.bzl.md#openssl_build
