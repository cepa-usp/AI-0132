package 
{
	import cepa.ai.IPlayInstance;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AI132PlayInstance implements IPlayInstance 
	{
		private var _playMode;
		private const cargaEletron:NotCi = new NotCi(1.6, -19); // coulombs
		public var answr_i:NotCi;
		public var answr_j:NotCi;
		private var tempo:Number = 0;
		private var qtde:int = 0;
		private var areaSecao:NotCi;
		public var exp_i:NotCi;
		public var exp_j:NotCi;
		public var acertouCorrente:Boolean = false;
		public var acertouDensidade:Boolean = false;
		private var score:Number = 0;
	
		
		public function AI132PlayInstance() 
		{
			
		}
		
		public function setMeasureData(tempo:Number, qtde:int, areaSecao:NotCi) {
			this.tempo = tempo;
			this.qtde = qtde;
			this.areaSecao = areaSecao;
		}
		
		public function getUserAnswers(i:NotCi, j:NotCi) {
			this.answr_i = i;
			this.answr_j = j;
		}
		
		
		/* INTERFACE cepa.ai.IPlayInstance */
		
		public function get playMode():int 
		{
			return _playMode;
		}
		
		public function set playMode(value:int):void 
		{
			_playMode = value;
		}
		
		public function returnAsObject():Object 
		{
			var obj:Object = { };
			obj.playMode = this.playMode;
			obj.answr_i = notCi2Obj(this.answr_i)
			obj.answr_j = notCi2Obj(this.answr_j)
			obj.tempo = this.tempo;
			obj.qtde = this.qtde;
			obj.areaSecao = notCi2Obj(this.areaSecao);
			obj.exp_i = notCi2Obj(this.exp_i);
			obj.exp_j = notCi2Obj(this.exp_j);
			obj.score = this.score;
			return obj;
		}
		
		public function bind(obj:Object):void 
		{
			this.playMode = obj.playMode;
			this.answr_i = Obj2NotCi(obj.answr_i);
			this.answr_j = Obj2NotCi(obj.answr_j);
			this.areaSecao = Obj2NotCi(obj.areaSecao);
			this.tempo = obj.tempo
			this.qtde =  obj.qtde
			this.exp_i = Obj2NotCi(obj.exp_i);
			this.exp_j = Obj2NotCi(obj.exp_j);
			this.score = obj.score;			
		}
		
		public function getScore():Number 
		{
			return score;
		}
		
		public function evaluate():void 
		{
			trace("passou 00")
			
			
			var count:Number = qtde;			
			var time:Number = this.tempo;
			
			score = 0;
			
			exp_i = new NotCi(count / time, 0);
			exp_i.multiplicar(cargaEletron);
			
			exp_j= new NotCi(exp_i.mantissa, exp_i.ordem);
			exp_j.dividir(this.areaSecao);
			
			
			score += (match(exp_i.mantissa , answr_i.mantissa, 0)?.25:0);
			score += (match(exp_i.ordem , answr_i.ordem, 0)?.25:0);
			score += (match(exp_j.mantissa , answr_j.mantissa, 0)?.25:0);
			score += (match(exp_j.ordem , answr_j.ordem, 0)?.25:0);
			
			acertouCorrente = false;
			if (match(exp_i.mantissa , answr_i.mantissa, 0) && match(exp_i.ordem , answr_i.ordem, 0)) acertouCorrente = true;

			acertouDensidade = false;
			if (match(exp_j.mantissa , answr_j.mantissa, 0) && match(exp_j.ordem , answr_j.ordem, 0)) acertouDensidade = true;

			score *= 100;

		}
		
		private function match(v1:Number, v2:Number, tolerance:Number):Boolean {
			return (v1 == v2) 
		}
		
		private function notCi2Obj(nc:NotCi):Object { 
			if (nc == null) return null;
			return { mantissa: nc.mantissa, ordem:nc.ordem };
		}
		
		private function Obj2NotCi(o:Object):NotCi {			
			try {			 
				return new NotCi(Number(o.mantissa), Number(o.ordem));
			} catch (e:Error) {
				return null; 
			}		
			return null;
		}
	}

}