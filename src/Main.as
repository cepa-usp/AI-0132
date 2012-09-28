﻿package 
{
	import cepa.ai.AI;
	import cepa.ai.AIObserver;
	import cepa.eval.ProgressiveEvaluator;
	import cepa.eval.StatsScreen;
	import cepa.utils.ToolTip;
	import fl.motion.easing.Elastic;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	import AI132PlayInstance;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends MovieClip implements AIObserver
	{
		//Camadas:
		private var background_layer:Sprite;
		private var contador_layer:Sprite;
		private var atividade_layer:Sprite;
		private var stuff_layer:Sprite;
		private var cronometro:Cronometro;
		private var animation:Animation;
		private var warningScreen:WarningScreen;
		private var statsScreen:StatsScreen;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.scrollRect = new Rectangle(0, 0, 700, 480);
			
			createLayers();
			configAi();
			configMenuBar();
			initAreas();
			sortArea();
			addPointingArrow();
			addEventListener(Event.ENTER_FRAME, refreshCounter);
			//stage.addEventListener(Event.MOUSE_LEAVE, onFocusOut)
			
			
			//ajustaTextos(null);
			hideAnswer();
			
			ai = new AI(this);
			ai.container.setMessageTextVisible(false);
			ai.evaluator = new ProgressiveEvaluator(ai);
			statsScreen = new StatsScreen(ProgressiveEvaluator(ai.evaluator), ai);
			ai.addObserver(this);
			
			initLMSConnection();
		}
		
		private var originalFrameRate:int = stage.frameRate;
		private function onFocusOut(e:Event) {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onFocusIn)
			stage.frameRate = 0;
			//trace("saiu");
		}
		private function onFocusIn(e:Event) {
			//trace("entrou");
			stage.frameRate = originalFrameRate;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onFocusIn)
		}		
		
		/**
		 * Cria as camadas da atividade e adiciona na ordem certa ao palco.
		 */
		private function createLayers():void 
		{
			background_layer = new Sprite();
			contador_layer = new Sprite();
			atividade_layer = new Sprite();
			stuff_layer = new Sprite();
			
			addChild(background_layer);
			addChild(contador_layer);
			addChild(atividade_layer);
			addChild(stuff_layer);
			
			setChildIndex(stuff_layer, 0);
			//setChildIndex(atividade_layer, 0);
			setChildIndex(contador_layer, 0);
			setChildIndex(background_layer, 0);
			
			addChild(menuBar);
			
			warningScreen = new WarningScreen();
			stage.addChild(warningScreen);
			stage.setChildIndex(warningScreen, stage.numChildren - 1);
			
			
		}
		
		/**
		 * Faz as configurações iniciais da atividade, instanciando variáveis necessárias.
		 */
		private function configAi():void 
		{
			cronometro = new Cronometro();
			contador_layer.addChild(cronometro);
			cronometro.x = 195;
			cronometro.y = 139;
			cronometro.addEventListener("START_COUNTING", startCount);
			cronometro.addEventListener("STOP_COUNTING", stopCount);
			cronometro.addEventListener("RESET_COUNTING", resetCount);
			
			animation = new Animation();
			atividade_layer.addChild(animation);
			animation.y = 202;
			animation.mask = mascara;
			
			menuBar.btn_upDown.buttonMode = true;
			menuBar.btn_upDown.addEventListener(MouseEvent.CLICK, openCloseMenuBar);

			TextField(menuBar.corrente).autoSize = TextFieldAutoSize.NONE;
			TextField(menuBar.corrente).tabIndex = 1
			TextField(menuBar.expCorrente).autoSize = TextFieldAutoSize.NONE;
			TextField(menuBar.expCorrente).tabIndex = 2
			TextField(menuBar.densidade).autoSize = TextFieldAutoSize.NONE;
			TextField(menuBar.densidade).tabIndex = 3
			TextField(menuBar.expDensidade).autoSize = TextFieldAutoSize.NONE	;
			TextField(menuBar.expDensidade).tabIndex = 4;
			
			TextField(menuBar.corrente).restrict = "-1234567890.,";
			TextField(menuBar.expCorrente).restrict = "-1234567890.,";
			TextField(menuBar.densidade).restrict = "-1234567890.,";
			TextField(menuBar.expDensidade).restrict = "-1234567890.,";
			
			//TextField(menuBar.corrente).addEventListener(Event.CHANGE, ajustaTextos);
			//TextField(menuBar.expCorrente).addEventListener(Event.CHANGE, ajustaTextos);
			//TextField(menuBar.densidade).addEventListener(Event.CHANGE, ajustaTextos);
			//TextField(menuBar.expDensidade).addEventListener(Event.CHANGE, ajustaTextos);
			
			menuBar.btn_upDown.gotoAndStop("ABRIR");
		}
		
		private function configMenuBar():void 
		{
			menuBar.btAvaliar.gotoAndStop(1);
			menuBar.btAvaliar.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { menuBar.btAvaliar.gotoAndStop(2) } );
			menuBar.btAvaliar.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { menuBar.btAvaliar.gotoAndStop(1) } );
			
			menuBar.btNovamente.gotoAndStop(1);
			menuBar.btNovamente.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { menuBar.btNovamente.gotoAndStop(2) } );
			menuBar.btNovamente.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { menuBar.btNovamente.gotoAndStop(1) } );
			
			menuBar.btVerResposta.gotoAndStop(1);
			menuBar.btVerResposta.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { menuBar.btVerResposta.gotoAndStop(2) } );
			menuBar.btVerResposta.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { menuBar.btVerResposta.gotoAndStop(1) } );
			
			menuBar.answerCorrente.visible = false;
			menuBar.answerDensidade.visible = false;
			
			
			
			var ttAvaliar:ToolTip = new ToolTip(menuBar.btAvaliar, "Avaliar exercício", 12, 0.8, 200, 0.6, 0.6);
			var ttNovamente:ToolTip = new ToolTip(menuBar.btNovamente, "Nova tentativa", 12, 0.8, 200, 0.6, 0.6);
			var ttResposta:ToolTip = new ToolTip(menuBar.btVerResposta, "Ver/ocultar respostas", 12, 0.8, 200, 0.6, 0.6);
			
			var ttII:ToolTip = new ToolTip(menuBar.ii, "Corrente elétrica", 12, 0.8, 200, 0.6, 0.6);
			var ttJJ:ToolTip = new ToolTip(menuBar.jj, "Densidade de corrente elétrica", 12, 0.8, 200, 0.6, 0.6);
			
			stage.addChild(ttAvaliar);
			stage.addChild(ttNovamente);
			stage.addChild(ttResposta);
			stage.addChild(ttII);
			stage.addChild(ttJJ);
			
			menuBar.btVerResposta.verexerc.visible = false;
			menuBar.btVerResposta.visible = false;
			menuBar.btNovamente.visible = false;
			
			//eventListener do botão reset da moldura.
			//btnReset.addEventListener(MouseEvent.CLICK, reset);
			menuBar.btNovamente.addEventListener(MouseEvent.CLICK, reset);
			menuBar.btAvaliar.addEventListener(MouseEvent.CLICK, aval);
			menuBar.btVerResposta.addEventListener(MouseEvent.CLICK, showHideAnswer);
		}
		
		private function showHideAnswer(e:MouseEvent):void 
		{
			if (menuBar.btVerResposta.verresp.visible) {
				//Mostra resposta
				menuBar.btVerResposta.verresp.visible = false;
				menuBar.btVerResposta.verexerc.visible = true;
			}else {
				//esconde resposta
				menuBar.btVerResposta.verresp.visible = true;
				menuBar.btVerResposta.verexerc.visible = false;
			}
		}
		
		private var answerCorrente:NotCi;
		private var answerDensidade:NotCi;
		
		private var areaSecao:NotCi;
		private var expoenteAreaSecao:Number;
		
		private var areasSecao:Vector.<NotCi> = new Vector.<NotCi>();
		
		private function initAreas():void
		{
			areasSecao.push(new NotCi(10,-6));
			areasSecao.push(new NotCi(12, -6));
			areasSecao.push(new NotCi(15, -6));
			areasSecao.push(new NotCi(5, -7));
			areasSecao.push(new NotCi(2, -6));
			areasSecao.push(new NotCi(3, -6));
			areasSecao.push(new NotCi(4, -7));
		}
		
		private function sortArea():void
		{
			var rand:int = Math.floor(Math.random() * areasSecao.length);
			areaSecao = areasSecao[rand];
			animation.setArea(areaSecao.mantissa, areaSecao.ordem);
		}
		
		private function preCalc():void {
			var count:Number = Number(cronometro.counter.text);
			//var time:Number = Number(cronometro.display.text.replace(",", ".").replace("s", "")); //em segundos;
			var time:Number = cronometro.timer;
			var cargaEletron:NotCi =  new NotCi(1.6 , -19); // coulombs
			
			var a:NotCi = new NotCi(count / time, 0);
			a.multiplicar(cargaEletron);
			trace("RESPOSTA 1", a)

			var b:NotCi = new NotCi(a.mantissa, a.ordem);
			b.dividir(areaSecao);
			trace("RESPOSTA 2", b)
		}
		

		private function hideAnswer() {
			menuBar.txtRespostaDensidade.visible = false;
			menuBar.txtRespostaDensidadeExp.visible = false;
			menuBar.txtRespostaCorrente.visible = false;
			menuBar.txtRespostaCorrenteExp.visible = false;
			menuBar.correnteUnitAnswer.visible = false;
			menuBar.densidadeUnitAnswer.visible = false;
			unlockFields();
		}
		
		private function showAnswer(corrente:Boolean, densidade:Boolean) {
			if(!densidade){
				menuBar.txtRespostaDensidade.visible = true;
				menuBar.txtRespostaDensidadeExp.visible = true;
				menuBar.densidadeUnitAnswer.visible = true;
			}
			if(!corrente){
				menuBar.txtRespostaCorrente.visible = true;
				menuBar.txtRespostaCorrenteExp.visible = true;
				menuBar.correnteUnitAnswer.visible = true;
			}
			lockFields();
			
		}
		
		private function lockFields():void 
		{
			TextField(menuBar.corrente).mouseEnabled = false;
			TextField(menuBar.expCorrente).mouseEnabled = false;
			TextField(menuBar.densidade).mouseEnabled = false;
			TextField(menuBar.expDensidade).mouseEnabled = false;
		}
		
		private function unlockFields():void 
		{
			TextField(menuBar.corrente).mouseEnabled = true;
			TextField(menuBar.expCorrente).mouseEnabled = true;
			TextField(menuBar.densidade).mouseEnabled = true;
			TextField(menuBar.expDensidade).mouseEnabled = true;
		}
		
		private var avalOk:Boolean = false;
		private var actualScore:Number;
		
		/**
		 * Faz a avaliação do exercício.
		 */
		private function aval(e:MouseEvent):void 
		{
			if(avalOk){
			var playInstance:AI132PlayInstance = new AI132PlayInstance();

			var count:Number = Number(cronometro.counter.text);
			var time:Number = cronometro.timer; //em segundos;
			playInstance.setMeasureData(time, count, areaSecao);	
			var userCorrente:NotCi = new NotCi(Number(menuBar.corrente.text.replace(",",".")) , Number(menuBar.expCorrente.text.replace(",",".")));
			var userDensidade:NotCi = new NotCi(Number(menuBar.densidade.text.replace(",",".")) , Number(menuBar.expDensidade.text.replace(",",".")));
			playInstance.getUserAnswers(userCorrente, userDensidade);			
			playInstance.evaluate();
			answerCorrente = playInstance.exp_i;
			answerDensidade = playInstance.exp_j;
			
			ai.evaluator.addPlayInstance(playInstance);
			var r_corrente:Boolean = (playInstance.acertouCorrente);
			var r_densidade:Boolean = (playInstance.acertouDensidade);
			
			TextField(menuBar.txtRespostaCorrente).autoSize = TextFieldAutoSize.LEFT;
			TextField(menuBar.txtRespostaCorrente).autoSize = TextFieldAutoSize.LEFT;
			TextField(menuBar.txtRespostaDensidade).autoSize = TextFieldAutoSize.LEFT;
			menuBar.txtRespostaDensidade.text = "Resposta: " + answerDensidade.mantissa.toPrecision(2).replace(".", ",") + " x 10";
			menuBar.txtRespostaCorrente.text = "Resposta: " + answerCorrente.mantissa.toPrecision(2).replace(".", ",") + " x 10";
			menuBar.txtRespostaCorrenteExp.text = answerCorrente.ordem.toString();
			menuBar.txtRespostaDensidadeExp.text = answerDensidade.ordem.toString();
			menuBar.txtRespostaCorrenteExp.x = menuBar.txtRespostaCorrente.x + menuBar.txtRespostaCorrente.width + 2;
			menuBar.txtRespostaDensidadeExp.x = menuBar.txtRespostaDensidade.x + menuBar.txtRespostaDensidade.width + 2;			
			menuBar.correnteUnitAnswer.x = menuBar.txtRespostaCorrenteExp.x + menuBar.txtRespostaCorrenteExp.width;
			menuBar.densidadeUnitAnswer.x = menuBar.txtRespostaDensidadeExp.x + menuBar.txtRespostaDensidadeExp.width;
				
				
				menuBar.answerCorrente.visible = true;
				menuBar.answerDensidade.visible = true;
				
				(r_corrente?menuBar.answerCorrente.gotoAndStop("CERTO"):menuBar.answerCorrente.gotoAndStop("ERRADO"));
				(r_densidade?menuBar.answerDensidade.gotoAndStop("CERTO"):menuBar.answerDensidade.gotoAndStop("ERRADO"));
				
				showAnswer(r_corrente, r_densidade);
				
				
				menuBar.btAvaliar.visible = false;
				menuBar.btVerResposta.visible = true;
				menuBar.btVerResposta.verexerc.visible = false;
				menuBar.btVerResposta.verresp.visible = true;
				menuBar.btNovamente.visible = true;
			}else {
				warningScreen.openScreen();
			}
		}
		
		private function reset(e:MouseEvent):void 
		{
			TextField(menuBar.corrente).text = "";
			TextField(menuBar.expCorrente).text = "";
			TextField(menuBar.densidade).text = "";
			TextField(menuBar.expDensidade).text = "";
			//ajustaTextos(null);
			hideAnswer();
			cronometro.reset();
			sortArea();
			
			animation.resetAnimation();
			
			menuBar.btVerResposta.verexerc.visible = false;
			menuBar.btVerResposta.verresp.visible = true;
			menuBar.btVerResposta.visible = false;
			menuBar.btNovamente.visible = false;
			menuBar.btAvaliar.visible = true;
			menuBar.answerCorrente.visible = false;
			menuBar.answerDensidade.visible = false;
		}
		
		private function ajustaTextos(e:Event):void 
		{
			menuBar.correnteMult.x = menuBar.corrente.x + menuBar.corrente.width;
			menuBar.expCorrente.x = menuBar.correnteMult.x + menuBar.correnteMult.width;
			menuBar.correnteUnit.x = menuBar.expCorrente.x + menuBar.expCorrente.width;
			
			menuBar.densidadeMult.x = menuBar.densidade.x + menuBar.densidade.width;
			menuBar.expDensidade.x = menuBar.densidadeMult.x + menuBar.densidadeMult.width;
			menuBar.densidadeUnit.x = menuBar.expDensidade.x + menuBar.expDensidade.width;
			
			var posCorrente:Number = menuBar.correnteUnit.x + menuBar.correnteUnit.width + 20;
			var posDensidade:Number = menuBar.densidadeUnit.x + menuBar.densidadeUnit.width + 20;
			
			if(posCorrente > posDensidade){
				menuBar.answerCorrente.x = posCorrente;
				menuBar.answerDensidade.x = posCorrente;
			}else {
				menuBar.answerCorrente.x = posDensidade;
				menuBar.answerDensidade.x = posDensidade;
			}
			//hideAnswer();
		}
		
		private var menuOpen:Boolean = false;
		private var tweenMenu:Tween;

		private function openCloseMenuBar(e:MouseEvent):void
		{
			if(menuOpen){
				menuOpen = false;
				tweenMenu = new Tween(menuBar, "y", None.easeNone, menuBar.y, 476, 0.3, true);
			}else{
				menuOpen = true;
				tweenMenu = new Tween(menuBar, "y", None.easeNone, menuBar.y, 355, 0.3, true);
			}
			tweenMenu.addEventListener(TweenEvent.MOTION_FINISH, changeBtnUpDown);
		}

		private function changeBtnUpDown(e:TweenEvent):void
		{
			if(menuOpen){
				menuBar.btn_upDown.gotoAndStop("FECHAR");
			}else{
				menuBar.btn_upDown.gotoAndStop("ABRIR");
			}
		}
		
		private var pointingArrow:PointingArrow;
		private function addPointingArrow():void 
		{
			pointingArrow = new PointingArrow();
			pointingArrow.x = 640 - 25;
			pointingArrow.y = 25;
			pointingArrow.filters = [new GlowFilter(0x800000, 1, 10, 10)];
			stage.addChild(pointingArrow);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, removeArrow);
		}
		
		private var arrEvtType:String = MouseEvent.MOUSE_DOWN;
		private function addPointingArrow2(pos:Point, obj:DisplayObject, eventType:String, inverse:Boolean=false):void 
		{
			if (pointingArrow != null) {
				menuBar.removeChild(pointingArrow);
			}
			pointingArrow = new PointingArrow();
			pointingArrow.x = pos.x;
			pointingArrow.y = pos.y;
			pointingArrow.filters = [new GlowFilter(0x800000, 1, 10, 10)];
			//stage.addChild(pointingArrow);
			menuBar.addChild(pointingArrow);
			arrEvtType = eventType;
			if (inverse) pointingArrow.scaleX = -1;
			obj.addEventListener(eventType, removeArrow);
		}

		
		private function removeArrow(e:MouseEvent):void
		{
			if (pointingArrow == null) return;
			stage.removeEventListener(arrEvtType, removeArrow);
			if(menuBar.contains(pointingArrow)) menuBar.removeChild(pointingArrow);
			else if (stage.contains(pointingArrow)) stage.removeChild(pointingArrow);
			pointingArrow = null;
		}
		
		/**
		 * Atualiza o contador de elétrons.
		 */
		private function refreshCounter(e:Event):void 
		{
			cronometro.counter.text = String(animation.eletronsCount);
		}
		
		private function resetCount(e:Event):void 
		{
			avalOk = false;
			animation.stopCounting();
			animation.resetCount();
		}
		
		private function startCount(e:Event):void 
		{
			avalOk = false;
			animation.startCounting();
		}
		
		private function stopCount(e:Event):void 
		{
			animation.stopCounting();
			preCalc();
			askForAnswer();
			avalOk = true;
		}
		
		private var tweenArrow:Tween;
		private function askForAnswer() {
			if (!menuOpen) {
				openCloseMenuBar(null);
			}
			//menuBar.y = 355;
			//menuOpen = true;
			//menuBar.btn_upDown.gotoAndStop("FECHAR");
			//addPointingArrow2(new Point(120, 400), menuBar, MouseEvent.MOUSE_OVER, true)
			addPointingArrow2(new Point(25, 40), menuBar, MouseEvent.MOUSE_OVER, true)
			pointingArrow.gotoAndStop(1);
			//if (tweenArrow != null) {
				//if(tweenArrow.isPlaying) 
			//}
			tweenArrow = new Tween(pointingArrow, "x", Elastic.easeOut, 200, 120, 3, true)
			menuBar.expCorrente.text = "0";
			menuBar.expDensidade.text="0";
			stage.focus = menuBar.corrente;
			
		}
		
		
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:Number = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		private var ai:AI;
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				//mementoSerialized = String(scorm.get("cmi.suspend_data"));
				var stringScore:String = scorm.get("cmi.score.raw");
			 
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				//txNota.text = score.toFixed(1).replace(".", ",");
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				//success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus():void
		{
			if(ExternalInterface.available){
				//mementoSerialized = marshalObjects();
				//scorm.set("cmi.suspend_data", mementoSerialized);
			}
		}
		

		

		/* INTERFACE cepa.ai.AIObserver */
		
		public function onResetClick():void 
		{
			
		}
		
		public function onScormFetch():void 
		{
			
		}
		
		public function onScormSave():void 
		{
			
		}
		
		public function onStatsClick():void 
		{
			statsScreen.openStatScreen();
		}
		
		public function onTutorialClick():void 
		{
			
		}
		
		public function onScormConnected():void 
		{
			
		}
		
		public function onScormConnectionError():void 
		{
			
		}
				
		
	}

}