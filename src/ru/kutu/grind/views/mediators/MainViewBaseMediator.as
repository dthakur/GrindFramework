package ru.kutu.grind.views.mediators  {
	
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;
	
	import ru.kutu.grind.views.api.IMainView;
	
	public class MainViewBaseMediator extends Mediator {
		
		[Inject] public var logger:ILogger;
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IMainView;
		[Inject] public var player:MediaPlayer;
		
		override public function initialize():void {
			var loaderInfo:LoaderInfo = contextView.view.loaderInfo;
			
			// Register the global error handler.
			if (loaderInfo && "uncaughtErrorEvents" in loaderInfo) {
				loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			}
			
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
//			trace(event.state);
			switch (event.state) {
				case MediaPlayerState.UNINITIALIZED:
					view.initializing();
//					view.setCurrentState("initializing");
					break;
				case MediaPlayerState.PLAYBACK_ERROR:
					view.error();
//					view.setCurrentState("error");
					break;
				case MediaPlayerState.PLAYING:
				case MediaPlayerState.READY:
					view.ready();
//					view.setCurrentState("ready");
					break;
			}
		}
		
		protected function onMediaError(event:MediaErrorEvent):void {
			view.errorText = [
				"Error:",
				event.error.message,
				event.error.detail
			].join("\n");
			
			CONFIG::LOGGING {
				logger.error(event.error);
			}
		}
		
		protected function onUncaughtError(event:UncaughtErrorEvent):void {
			event.preventDefault();
			
			var message:String;
			if (event.error is Error) {
				message = Error(event.error).message;
			} else if (event.error is ErrorEvent) {
				message = ErrorEvent(event.error).text;
			} else {
				message = event.error.toString();
			}
			
			CONFIG::LOGGING {
				logger.error(message);
			}
		}
		
	}
	
}