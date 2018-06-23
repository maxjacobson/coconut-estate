# coconut estate

## setting up your dev environment

* Install Rust 1.26+ <https://rustup.rs/>
* Install Terraform

## Building for production

This is somewhat hypothetical, but I think the idea is:

* Make sure you've got `rustup` installed and the right toolchain/target installed:

  ```shell
  rustup target add --toolchain stable x86_64-unknown-linux-gnu
  ```

* Cross-compile the binary for a linux server on production:

  ```shell
  bin/production-build secrets_keeper

  # find the binary here:
  find target/x86_64-unknown-linux-gnu/release -name "*secrets_keeper"
  ```

## Style guide

- For Rust code: run `rustfmt`
- For Markdown: don't hard-wrap text at any particular column.
  Instead, do one line per sentence.
  It feels and looks weird at first and then it's _omg so nice_ to not have to rewrap paragraphs when tweaking stuff you wrote before.
  And when rendered as HTML, it shows up like a regular paragraph.
  At least, in my opinion.
- For Git:
  - please follow [this guide][git-commit-messages] to writing good commit messages.
  - please avoid [merge bubbles]
  - please name the default branch of all repositories "edge"

[git-commmit-messages]: :https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[merge bubbles]: https://stackoverflow.com/a/26239382

## Production

We're hosted on DigitalOcean and using Terraform to describe our infrastructure and create resources.
See terraform/README.md for details on using Terraform.
