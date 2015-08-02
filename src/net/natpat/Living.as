package net.natpat 
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.natpat.utils.Key;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Living 
	{
		protected var needToUpdate:Boolean = false;
		
		private var map:Map;
		protected var x:Number, y:Number;
		
		
		private var size:int = 25;
		protected var speed:Number = 180;
		
		public function Living(map:Map) 
		{
			this.map = map;
			x = map.getSpawnLocation().x * Cell.SIZE;
			y = map.getSpawnLocation().y * Cell.SIZE;
		}
		
		protected function canStand(x:Number, y:Number):Boolean
		{
			var left:int = x - size / 2;
			var right:int = x + size / 2;
			var top:int = y - size / 2;
			var bottom:int = y + size / 2;
			left /= Cell.SIZE;
			right /= Cell.SIZE;
			top /= Cell.SIZE;
			bottom /= Cell.SIZE;
			if (map.getCell(left, top) != Cell.AIR ||
			    map.getCell(left, bottom) != Cell.AIR ||
				map.getCell(right, top) != Cell.AIR ||
				map.getCell(right, bottom) != Cell.AIR)
			{
				return false;
			}
			return true;
		}
		
		public function updatePosOnMap():void
		{
			map.setObjPos(this, x, y);
		}
		
		public function render(buffer:BitmapData):void
		{
			buffer.fillRect(new Rectangle(x - size / 2, y - size, size, size * 3/2), 0xffff0000);
		}
		
		
		public function shouldSendUpdate():Boolean
		{
			return needToUpdate;
		}
		public function sentUpdate():void
		{
			needToUpdate = false;;
		}
		
		public function toNetworkString():String
		{
			var s:String = "";
			s += x + "," + y;
			return s;
		}
		
		public function getPos():Point
		{
			return new Point(x, y);
		}
	}

}