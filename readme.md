URLLoaderVFS
=================
This VFS is based on the HTTP VFS that comes with Flascc, but it doesn't need your file to be processed by genfs before using them. So it allow you to change your asset without rebundling with genfs, which is really useful during dev. In theory you could even change the file externally at runtime, but that would require you to reload the manifest.


Usage:
--------
In your AS3 code :

	vfsURL = new URLLoaderVFS();
	vfsURL.loadManifest("file://path/to/manifest");
	vfsURL.addEventListener(Event.COMPLETE, onLoadedVFS);
	
	private function onLoadedVFS(event:Event):void {
		CModule.vfs.addBackingStore(vfsURL, "/")
		CModule.startAsync(this);
	}

Exactly the same as the HTTP VFS except for the "loadManifest".

In your manifest:

	Realpath                             fakePath
	RealAndFakePath
	c:/Windows/Style/Path/AFile.lua     /AFile.lua
	http://aWebSite.com/file.txt        /file.tx
	/Unix/Style/Path/foo.bar           /foo/bar.bar

You put one file per line, separate the real and fake path with space (real path is where you can find the real file on your file system or on the web, it is the string given to URLLoader. The fake path is where your c++ will see the file on the VFS once loaded in your Flascc app). If you want to use the same path for both and simulate your real file system, just put one path, it will be used for both(It may not work with absolute path on windows since flascc use unix style path.) You can also use website for the realpath (You can use whatever URLLoader would take).

Enjoy!

