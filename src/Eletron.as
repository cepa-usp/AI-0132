package  {
	import flash.display.MovieClip
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	public class Eletron extends MovieClip{
		
		private var angle:Number; //20 - 60
		private var k:Number = 0.098; //"gravidade"
		private var velInitX:Number; //0 - 10
		private var velInitY:Number; //0 - 10
		private var tx:Number;
		//private var step_t:Number = 2;
		private var step_t:Number;
		private var tmin:Number;
		private var tmax:Number;
		
		private var radius:Number = 8;
		private var heightLimit:Number = 220;
		private var s0x:Number;
		private var s0y:Number;
		
		private var timer:Timer;
		private var ty:Number;
		private var timerDelay:int;
		private var _finished:Boolean = false;
		
		private var _crossed:Boolean = false;
		
		//public function Eletron() {
		public function Eletron(step:Number, tmin:Number, tmax:Number) {
			this.step_t = step;
			this.tmin = tmin;
			this.tmax = tmax;
			tx = 0;
			ty = 0;
			angle = 0;
			velInitX = 0;
			velInitY = 0;
			timerDelay = int(rand(tmin, tmax));
			//timerDelay = int(rand(850, 1500));
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, updatePos);
			//timer.start();
		}
		
		public function startMoving():void 
		{
			s0x = this.x;
			s0y = this.y;
			
			sortDirections();
			
			addEventListener(Event.ENTER_FRAME, movePart);
			timer.start();
		}
		
		public function stopMoving():void
		{
			timer.removeEventListener(TimerEvent.TIMER, updatePos);
			timer.stop();
			removeEventListener(Event.ENTER_FRAME, movePart);
		}
		
		public function configEletron(step:Number, tmin:Number, tmax:Number):void
		{
			this.step_t = step;
			timerDelay = int(rand(tmin, tmax));
			//timerDelay = int(rand(850, 1500));
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, updatePos);
			//timer.start();
		}
		
		private function movePart(e:Event):void
		{
			if (this.y < 2 * radius && velInitY > 0) {
				velInitY = velInitY * ( -1);
				ty = 0;
				s0y = this.y;
			}else if (this.y > heightLimit - 2 * radius && velInitY < 0) { 
				velInitY = velInitY * ( -1);
				ty = 0;
				s0y = this.y;
			}
			//Balística invertida
			this.x = s0x - velInitX * Math.sin(angle) * tx + k * tx * tx / 2;
			this.y = s0y - velInitY * Math.cos(angle) * ty;
			
			tx = tx + step_t;
			ty = ty + step_t;
		}
		
		private function updatePos(e:TimerEvent):void 
		{
			timer.reset();
			s0x = this.x;
			s0y = this.y;
			sortDirections();
			timer.start();
		}
		
		/**
		 * Sorteia novas posições iniciais - "colisão"
		 */
		private function sortDirections():void {
			angle = rand(20, 60) * Math.PI / 180;
			velInitX = rand(0, 2);
			if (velInitY < 0) {velInitY = -1 * velInitX;}
			else {velInitY = velInitX;}
			tx = 0;
			ty = 0;
		}
		
		public function get crossed():Boolean 
		{
			return _crossed;
		}
		
		public function set crossed(value:Boolean):void 
		{
			_crossed = value;
		}
		
		public function get finished():Boolean 
		{
			return _finished;
		}
		
		public function set finished(value:Boolean):void 
		{
			_finished = value;
		}
		
		/**
		 * Função que calcula numeros aleatórios entre 2 numeros
		 * @param	min
		 * @param	max
		 * @return  numero
		 */
		private function rand(min:Number, max:Number):Number {
			
			var aux;
			
			aux = Math.random() * (1+max-min) + min;
			
			return aux;
		}
	}
	
}
