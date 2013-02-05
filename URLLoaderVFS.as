
package com.adobe.flascc.vfs
{
import flash.display.Loader;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Endian;


public class URLLoaderVFS extends InMemoryBackingStore
{


	private var bytesLoaded:uint
	private var percentComplete:uint
	private var currentLoader:URLLoader
	private var currentVPath:String
	private var currentUrls:Array = []
	private var currentContents:ByteArray
	var urlLoader:URLLoader
	private var vfsFiles:Array;

	public function URLLoaderVFS()
	{


	}


	public function loadManifest(path:String ="./manifest"):void {
		urlLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, onManifestLoaded);
		urlLoader.load(new URLRequest(path));
	}


	private function onManifestLoaded(e:Event):void {
		vfsFiles =  e.target.data.split(/\n/);
		startNewFile();
	}




	private function startNewFile():void{
		if(currentVPath == null)
		{
			var newfile:String = vfsFiles.shift()
			if(newfile == null)
			{
				// All files finished
				this.dispatchEvent(new Event(Event.COMPLETE));
				return
			}

			var paths:Array = newfile.split(" ");
			var filterFunc:Function = function(path:String, index:int, array:Array){return (path != "");};
			paths = paths.filter(filterFunc);

			var realPath:String;
			var calculatedPath:String;
			if(paths.length >1){
				realPath = paths[0];
				calculatedPath = paths[1];
			}
			else{
				realPath = paths[0];
				calculatedPath = realPath;
			}

			currentVPath = calculatedPath;
			currentContents = new ByteArray()
			currentContents.endian = Endian.LITTLE_ENDIAN
			currentContents.position = 0
			currentUrls.length = 0
			currentUrls.push(realPath);
		}

		startNewDownload();
	}

	private function startNewDownload():void
	{
		var url:String = currentUrls.shift()
		if(url == null) {

			addFile(currentVPath, currentContents);

			currentVPath = null
			startNewFile()
			return
		}

		currentLoader = new URLLoader(new URLRequest(url));
		currentLoader.dataFormat= URLLoaderDataFormat.BINARY;
		currentLoader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
		currentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
		currentLoader.addEventListener(IOErrorEvent.IO_ERROR, onError)
		currentLoader.addEventListener(Event.COMPLETE, onComplete)
		currentLoader.addEventListener(ProgressEvent.PROGRESS, onProgress)
	}

	private function onComplete(e:Event):void
	{
		bytesLoaded += currentLoader.data.length
		currentContents.writeBytes(currentLoader.data)

		startNewDownload()
	}

	private function onError(e:Event):void
	{
		this.dispatchEvent(e)
	}

	private function onProgress(e:Event):void
	{
		
	}
}