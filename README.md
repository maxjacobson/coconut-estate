# coconut estate

## setting up your dev environment

* Install Rust 1.26+ <https://rustup.rs/>
* Install Terraform
* Install npm
* Install docker (used to run PostgreSQL locally and to build cross-compiled binaries for production)

## Deploying to production

See the various `bin/deploy-*` scripts.

## Interacting with the database

### Some initial setup:

* Create and fill in `dev.env` (see `dev.env.example`)
* Create and fill in `prod.env` (see `prod.env.example`)

### Migrating the schema

* To generate a new migration: `diesel migration generate create_roadmaps`
* Fill in the generated `up.sql` and `down.sql` files
* To apply the change in development: `bin/diesel_dev migration run`
* To apply the change in production:
  * Start an SSH tunnel so the diesel CLI on your system can access production: `bin/database-start-tunnel`
  * `bin/diesel_prod migration run`

### Opening an interactive database shell

* In development:
  * Make sure the database is running (`bin/database` or `bin/development-environment`)
  * `bin/psql_dev`
* In production:
  * `bin/psql_prod`

## Style guide

Please run `bin/lint` before committing (consider running it as part of a before-commit hook).
Running `bin/delint` will fix most issues surfaced there.

- For Rust code: follow `rustfmt` (in `bin/lint`)
- For Terraform code, follow `terraform fmt` (in `bin/lint`)
- For JavaScript, I like Standard and I'd like to return it, but I'm new to ember and for now I'm following their conventions, which is a particular ember-specific eslint configuration (in `bin/lint`)
- For Markdown: don't hard-wrap text at any particular column.
  Instead, do one line per sentence.
  It feels and looks weird at first and then it's _omg so nice_ to not have to rewrap paragraphs when tweaking stuff you wrote before.
  And when rendered as HTML, it shows up like a regular paragraph.
  At least, in my opinion.
- For Git:
  - please follow [this guide][git-commit-messages] to writing good commit messages.
  - please avoid [merge bubbles]
  - please name the default branch of all repositories "edge"

[git-commit-messages]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[merge bubbles]: https://stackoverflow.com/a/26239382

## Conventions for development port numbers

I like the number 5, so all of the local things are running on ports that start with 5000 and go up:

- `localhost:5000` - website (ember app)
- `localhost:5001` - api
- `localhost:5002` - secrets-keeper
- `localhost:5432` - postgres

When creating SSH tunnels from localhost to a remote production resource, the port will be 1000 more than the development-environment port (just to help remember what it is):

- `localhost:6002` - secrets-keeper
- `localhost:6432` - postgres

## Production

We're hosted on DigitalOcean and using Terraform to describe our infrastructure and create resources.
See [terraform/README.md](terraform/README.md) for details on using Terraform.
