# Plugins
Plugins are used for generating platform specific code.

## Requirements
__Path__:
- Located at `plugins/<owner>/<repo>/`

__Naming__:
- Name must exactly match a release tag for the package or platform, followed by `.sh`.
    - IE: `0.12.3.sh`, or `v0.0.0-alpha1.sh`.

__Arguments__:
- The plugin should take the following arguments:
1) The file name
2) The platform alias
3) The platform url
4) Zero or more pairs of package alias and url arguments

__Plugin availability__:
- roc-start will always use the plugin with the highest version which is less than or equal to the target platform version.
- If no plugins are available for a platform, roc-start will default to a basic template which only includes the app header, and no additional code.
- If the first plugin available for a platform is not the first release, this default template will be used for initialization with versions prior to the first available plugin.
-  Plugins only need to be made available for platform releases which introduce breaking changes. Otherwise the highest plugin which is less than or equal to the target version will be used, or the default template if none is available.

