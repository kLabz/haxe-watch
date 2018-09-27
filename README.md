# Haxe Watcher

Use this tool (`watch` executable) instead of `haxe` in your terminal to
automatically watch your sources for changes and recompile.

Installation: clone somewhere, add the directory to your `PATH` or symlink
`watch` in a directory included in your `PATH`. Do **not** move `watch` alone
without `Watcher.hx`, this wouldn't work anymore.

## Example usage

```
# Instead of haxe build.hxml:
watch build.hxml
```
