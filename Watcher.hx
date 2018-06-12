package;

import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import sys.FileSystem;

class Watcher {
	static function waitForChange():Void {
		var watchedFolders = [];
		// var watchedResources = [];

		var watcherPath = Compiler.getDefine("watcher-path");
		#if !watch_std
		var std = FileSystem.absolutePath(Sys.getEnv("HAXE_STD_PATH"));
		#end

		var cp = Context.getClassPath();
		for (c in cp) {
			if (c == '') continue;
			c = FileSystem.absolutePath(c);

			// Ignore watcher path
			if (StringTools.startsWith(c, watcherPath)) continue;

			#if !watch_std
			// Ignore changes in std
			if (StringTools.startsWith(c, std)) continue;
			#end

			var watched = getWatched(c);
			if (watched.length > 0) watchedFolders = watchedFolders.concat(watched);
		}

		// TODO: find a way to watch resources
		// Seems impossible atm...

		// TODO: watch hxml files?

		Sys.println(
			#if !watch_no_color '\x1b[90m' #end
			+ 'Watching ${watchedFolders.length} directories'
			// + ' and ${watchedResources.length} resources '
			+ ' for changes...'
			#if !watch_no_color + '\x1b[0m' #end
		);

		var changed = false;
		var buildDate = Date.now().getTime() + 100;
		while (!changed) {
			Sys.sleep(1.);

			for (f in watchedFolders) {
				var t = FileSystem.stat(f).mtime.getTime();
				if (t > buildDate) {
					#if watch_debug
					Sys.println(
						#if !watched_no_color '\x1b[90m' #end
						+ 'Changes detected in $f'
						#if !watched_no_color + '\x1b[0m' #end
					);
					#end

					changed = true;
					break;
				}
			}
		}

		Sys.println("\x1b[32mChanges detected, rebuilding...\x1b[0m");
		Sys.exit(0);
	}

	static function getWatched(path:String):Array<String> {
		var ret = [path];

		for (f in FileSystem.readDirectory(path)) {
			var fpath = Path.join([path, f]);
			if (FileSystem.isDirectory(fpath)) {
				if (StringTools.startsWith(f, '.')) continue;

				ret.push(fpath);
				var watched = getWatched(fpath);
				if (watched.length > 0) ret = ret.concat(watched);
			}
		}

		return ret;
	}
}

