package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Animation extends Sprite
	{
		//Camadas:
		private var eletronsLayer:Sprite;
		private var secaoFundoLayer:Sprite;
		private var secaoFrenteLayer:Sprite;
		
		private var eletrons:Vector.<Eletron> = new Vector.<Eletron>();
		private var pilha:Vector.<Eletron> = new Vector.<Eletron>();
		private var timerToCreateEletrons:Timer;
		
		private var counting:Boolean = false;
		private var _eletronsCount:int = 0;
		
		private var configuracoes:Vector.<Object> = new Vector.<Object>();
		private var configAtual:Object;
		
		public function Animation() 
		{
			createLayers();
			addListeners();
			createConfigs();
			sortConfig();
			startAnimation();
			addEventListener(Event.ENTER_FRAME, checkEletronsSecao);
		}
		
		private function createLayers():void 
		{
			//secaoFundoLayer = new Sprite();
			//addChild(secaoFundoLayer);
			eletronsLayer = new Sprite();
			addChild(eletronsLayer);
			//secaoFrenteLayer = new Sprite();
			//addChild(secaoFrenteLayer);
			
			//secaoFundoLayer.addChild(secaoFundo);
			//secaoFrenteLayer.addChild(secaoFrente);
			//secaoFrenteLayer.addChild(mcArea);
		}
		
		private function addListeners():void 
		{
			//secaoFundo.buttonMode = true;
			//secaoFrente.buttonMode = true;
			//secaoFundo.addEventListener(MouseEvent.MOUSE_OVER, showArea);
			//secaoFundo.addEventListener(MouseEvent.MOUSE_OUT, hideArea);
			//secaoFrente.addEventListener(MouseEvent.MOUSE_OVER, showArea);
			//secaoFrente.addEventListener(MouseEvent.MOUSE_OUT, hideArea);
			//mcArea.visible = false;
		}
		
		private function showArea(e:MouseEvent):void 
		{
			//mcArea.visible = true;
		}
		
		private function hideArea(e:MouseEvent):void 
		{
			//mcArea.visible = false;
		}
		
		public function setArea(area:Number, exp:int):void
		{
			//this.mcArea.area.text = String(area).replace(".", ",") + " x 10";
			//this.mcArea.expoente.text = String(exp);
		}
		
		private function createConfigs():void 
		{
			configuracoes.push({step: 2, 	tmin:850, tmax:1500, 	delayMin:0.5, 	delayMax:2});
			configuracoes.push({step: 2.5, 	tmin:750, tmax:1200, 	delayMin:0.4, 	delayMax:1.8});
			configuracoes.push({step: 3, 	tmin:650, tmax:1000, 	delayMin:0.35, 	delayMax:1.5});
			configuracoes.push({step: 3.5, 	tmin:550, tmax:850, 	delayMin:0.3, 	delayMax:1.2});
			configuracoes.push({step: 4, 	tmin:450, tmax:700, 	delayMin:0.25, 	delayMax:1});
			configuracoes.push({step: 4.5, 	tmin:350, tmax:600, 	delayMin:0.2, 	delayMax:0.8});
			configuracoes.push({step: 5, 	tmin:250, tmax:500, 	delayMin:0.15, 	delayMax:0.6});
		}
		
		private function sortConfig():void 
		{
			var sort:int = Math.floor(Math.random() * configuracoes.length);
			//var sort:int = 0;
			configAtual = configuracoes[sort];
		}
		
		/**
		 * Inicia a animação dos elétrons.
		 */
		private function startAnimation():void 
		{
			pilha = new Vector.<Eletron>();
			//timerToCreateEletrons = new Timer(getDelay(0.5, 2), 1);
			timerToCreateEletrons = new Timer(getDelay(configAtual.delayMin, configAtual.delayMax), 1);
			timerToCreateEletrons.addEventListener(TimerEvent.TIMER_COMPLETE, addEletron);
			timerToCreateEletrons.start();
		}
		
		public function resetAnimation():void
		{
			timerToCreateEletrons.removeEventListener(TimerEvent.TIMER_COMPLETE, addEletron);
			//removeEventListener(Event.ENTER_FRAME, checkEletronsSecao);
			
			//for each(var eletron:Eletron in eletrons) {
				//if(eletronsLayer.contains(eletron)) eletronsLayer.removeChild(eletron);
			//}
			//
			//eletrons.splice(0, eletrons.length - 1);
			
			sortConfig();
			//addEventListener(Event.ENTER_FRAME, checkEletronsSecao);
			startAnimation();
		}
		
		private function addEletron(e:TimerEvent):void 
		{
			timerToCreateEletrons.removeEventListener(TimerEvent.TIMER_COMPLETE, addEletron);
			
			//Adiciona o elétron
			var eletron:Eletron 
			if(pilha.length==0){
				eletron = new Eletron(configAtual.step, configAtual.tmin, configAtual.tmax);
				eletrons.push(eletron);
			} else {
				eletron = pilha.pop();
				eletron.finished = false;
				eletron.crossed = false;				
			}
			eletronsLayer.addChild(eletron);
			var posEletron:Point = getPosition();
			eletron.x = posEletron.x;
			eletron.y = posEletron.y;
			eletron.startMoving();

			//reinicia o timer
			startAnimation();
		}
		
		private function checkEletronsSecao(e:Event):void 
		{
			//var eletronsToRemove:Vector.<Eletron> = new Vector.<Eletron>();
			
			for each(var eletron:Eletron in eletrons) {
				if (eletron.x > 100 && !eletron.crossed && !eletron.finished) {
					eletron.crossed = true;
					//eletron.filters = [new GlowFilter()];
					if(counting) _eletronsCount++;
				} else if (eletron.x > 500 && !eletron.finished) {
					//eletronsToRemove.push(eletron);
					
					//eletron.stopMoving();
					eletron.finished = true;
					if(eletronsLayer.contains(eletron)) eletronsLayer.removeChild(eletron);
					pilha.push(eletron);
				}
			}
			
			//for (var i:int = 0; i < eletronsToRemove.length; i++) 
			//{
				//if (eletronsLayer.contains(eletronsToRemove[i])) eletronsLayer.removeChild(eletronsToRemove[i]);
				//eletrons.splice(eletrons.indexOf(eletronsToRemove[i]), 1);
				//eletronsToRemove.pop(
			//}
			
			//eletronsToRemove.splice(0, eletronsToRemove.length - 1);
		}
		
		public function startCounting():void
		{
			counting = true;
		}
		
		public function stopCounting():void
		{
			counting = false;
		}
		
		private var heightFio:Number = 250;
		private function getPosition():Point 
		{
			var min:Number = 10;
			var max:Number = heightFio - (2 * min);
			var pos:Point = new Point( -10, (Math.random() * max) + min);
			return pos;
		}
		
		private function getDelay(min:Number, max:Number):Number
		{
			//var min:Number = 0.5;
			//var max:Number = 2;
			
			return ((Math.random() * (max - min)) + min) * 100;
		}
		
		public function get eletronsCount():int 
		{
			return _eletronsCount;
		}
		
		public function resetCount():void
		{
			_eletronsCount = 0;
			
		}
		
	}

}