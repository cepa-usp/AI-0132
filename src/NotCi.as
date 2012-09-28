package  
{
	
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public class NotCi 
	{
		private var _mantissa:Number;
		private var _ordem:Number;
		
		public function NotCi(mantissa:Number, ordem:Number) 
		{
			this.ordem = ordem;
			this.mantissa = mantissa;
			
		}
		
		public function get ordem():int 
		{
			return _ordem;
		}
		
		public function set valor(n:Number):void {
			ordem = 0;
			mantissa = n;
		}
		
		public function set ordem(value:int):void 
		{
			_ordem = value;
		}
		
		
		public function get mantissa():Number 
		{
			return _mantissa;
		}
		
		public function set mantissa(value:Number):void 
		{
			toScientific(value);
		}
		

function toScientific(num:Number):void {
	var exponent:Number = Math.floor(Math.log(Math.abs(num)) / Math.LN10);
	if (num == 0) exponent = 0;

	var tenToPower:Number = Math.pow(10, exponent);
	var xmantissa:Number = num / tenToPower;
//mantissa = formatDecimals(mantissa, sigDigs-1);
	ordem += exponent;
	_mantissa = xmantissa;
	//var output = mantissa;
} 		
		
		public function multiplicar(valor:NotCi):void {
			this.ordem += valor.ordem;
			this.mantissa *= valor.mantissa;
		}
		public function dividir(valor:NotCi):void {
			this.ordem -= valor.ordem;
			this.mantissa /= valor.mantissa;		
		}
		
		public function get valor():Number {
			return mantissa * Math.pow(10, ordem);
		}
		
		public function toString():String {
			return mantissa.toString() + " x 10^" + ordem.toString();
		}
		
	}
	
}