## native

```python
native: struct(..)
```

---
## openssl\_archive

```python
def openssl_archive(
    name: str,
    version: str,
    configure_file: str = "Configure",
    *args,
    **kwargs
)
```

Defines an OpenSSL source code archive.

name:
    Target name.
  version:
    OpenSSL version.

---
## openssl\_build

```python
def openssl_build(
    *,
    name: str,
    default_target_platform: None | str = _,
    target_compatible_with: list[str] = _,
    compatible_with: list[str] = _,
    exec_compatible_with: list[str] = _,
    visibility: list[str] = _,
    within_view: list[str] = _,
    metadata: opaque_metadata = _,
    tests: list[str] = _,
    archive: str,
    configure_flags: list[str] = _
) -> None
```

#### Parameters

* `name`: name of the target
* `default_target_platform`: specifies the default target platform, used when no platforms are specified on the command line
* `target_compatible_with`: a list of constraints that are required to be satisfied for this target to be compatible with a configuration
* `compatible_with`: a list of constraints that are required to be satisfied for this target to be compatible with a configuration
* `exec_compatible_with`: a list of constraints that are required to be satisfied for this target to be compatible with an execution platform
* `visibility`: a list of visibility patterns restricting what targets can depend on this one
* `within_view`: a list of visibility patterns restricting what this target can depend on
* `metadata`: a key-value map of metadata associated with this target
* `tests`: a list of targets that provide tests for this one
* `archive`: Archive returned by the `openssl_archive` macro.
* `configure_flags`: Configure flags.
