package;

import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import sys.FileSystem;

class Watcher {
	static function waitForChange():Void {
		var watchedFolders = [];
		var cp = Context.getClassPath();
		var watcherPath = Compiler.getDefine("watcher-path");

		#if !watch_std
		var std = FileSystem.absolutePath(Sys.getEnv("HAXE_STD_PATH"));
		#end

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

		var changed = false;
		var buildDate = Date.now().getTime() + 100;
		while (!changed) {
			Sys.sleep(1.);

			for (f in watchedFolders) {
				var t = FileSystem.stat(f).mtime.getTime();
				if (t > buildDate) {
					#if watch_debug
					Sys.println('\x1b[90m Changes detected in $f\x1b[0m');
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

