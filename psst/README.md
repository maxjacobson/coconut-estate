# psst

A small rust library for storing and retrieving little secrets.

* Provide a group name, such as "film-snob", and it will store secrets in `~/.local/share/film-snob/psst.toml`
* If the secret is already there, it will be returned, otherwise it will prompt for input and remember
