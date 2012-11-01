package  
{
	import cepa.utils.Cronometer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Cronometro extends Sprite
	{
		private var cron:Cronometer;
		
		public function Cronometro() 
		{
			configCron();
			addListeners();
			btn_play.visible = true;
			btn_pause.visible = false;
		}
		
		private function configCron():void 
		{
			cron = new Cronometer();
			display.text = "0";
		}
		
		private function addListeners():void 
		{
			btn_play.addEventListener(MouseEvent.CLICK, playFunc);
			btn_pause.addEventListener(MouseEvent.CLICK, stopFunc); //stop
			btn_reset.addEventListener(MouseEvent.CLICK, resetFunc);
		}
		
		private function playFunc(e:MouseEvent):void 
		{
			if(!cron.isRunning()){
				addEventListener(Event.ENTER_FRAME, refreshCron);
				dispatchEvent(new Event("RESET_COUNTING", true));
				dispatchEvent(new Event("START_COUNTING", true));
				cron.reset();
				cron.start();
			}
			btn_play.visible = false;
			btn_pause.visible = true;
		}
		
		private function refreshCron(e:Event):void 
		{
			display.text = (cron.read() / 1000).toFixed(1).replace(".", ",") + "s";
			if (cron.read() / 1000 > 59.9) {
				//removeEventListener(Event.ENTER_FRAME, refreshCron);
				//cron.pause();
				//cron.reset();
				//display.text = (cron.read() / 1000).toFixed(2).replace(".", ",") + "s";
				//dispatchEvent(new Event("STOP_COUNTING", true));
				stopFunc(null);
			}
		}
		
		private function stopFunc(e:MouseEvent):void 
		{
			if(cron.isRunning()){
				removeEventListener(Event.ENTER_FRAME, refreshCron);
				dispatchEvent(new Event("STOP_COUNTING", true));
				cron.pause();
				display.text = (cron.read() / 1000).toFixed(2).replace(".", ",") + "s";
			}
			btn_play.visible = true;
			btn_pause.visible = false;

		}
		
		private function resetFunc(e:MouseEvent):void 
		{
			if (cron.isRunning()) {
				removeEventListener(Event.ENTER_FRAME, refreshCron);
				cron.stop();
			}
			cron.reset();
			display.text = "0";
			dispatchEvent(new Event("RESET_COUNTING", true));
			btn_play.visible = true;
			btn_pause.visible = false;

		}
		
		public function reset():void
		{
			resetFunc(null);
		}
		
		public function get timer():Number
		{
			return Number((cron.read() / 1000).toFixed(2));
		}
		
	}

}