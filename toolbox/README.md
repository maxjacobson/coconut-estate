# toolbox

A CLI for operating production.

## Usage

```shell
bin/toolbox --help
```

If you aren't iterating on the toolbox and want to just build the CLI and then then use it for a while without re-compiling it, you can run:

```shell
cargo build --release --package toolbox
FAST=1 bin/toolbox --help
```

## Design goals

- Should be possible to figure out how to use it without reading the source code, because its built-in help text will guide you forward (thanks mostly to [clap])
- Should not care what is your current pwd when you run it.
  This is accomplished by always using absolute paths to files.
- Should be possible to start using right away without doing any setup.
  It should lazily prompt you for any secrets only when it needs them.
- Secrets should not be committed to the repository.

[clap]: https://crates.io/crates/clap
