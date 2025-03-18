# Roc-repo : the official repository for `roc-start`

This is the repository of packages, platforms, and plugins for the `roc-start` CLI tool. To get your package or platform listed in `roc-start`, simply make sure that you have a release of your package or platform which is tagged with a __valid semver_ version identifier, and then make a pull against this repository, adding your repository to either the `package.csv` file, or `platforms.csv`. The format is:

```csv
username/repo-name,alias,host
```
The alias is the short (lowercase) name you would like to be used when importing your package or platform, ie:
```
cli: platform "https://github.com/roc-lang/basic-cli/..."
```
> Note: currently only github is supported as a host, however other hosts may be added in future.

## Plugins

Plugins are shell scripts which generate platform specific code. These can be defined version by version. If no plugin is defined for a platform, `roc-start` will generate a generic app header for your platform. If a plugin is available for the platform, `roc-start` will use the most recent plugin version with the same or lower version than the requested platform version, or if no plugin matches this requirement, generate the generic app headers instead.

For more information on plugins, see the [plugins readme](plugins/README.md).

