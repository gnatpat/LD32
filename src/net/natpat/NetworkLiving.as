package net.natpat 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class NetworkLiving extends Living 
	{
		
		private var id:int;
		public var added:Boolean = false;
		protected var xToGet:Number, yToGet:Number;
		protected var dir:Point = new Point;
		
		public function NetworkLiving(map:Map, id:int) 
		{
			super(map);
			this.id = id;
		}
		
		public function getID():int
		{
			return id;
		}
		
		public function update():void
		{
			if (added)
			{
				dir.x = xToGet - x;
				dir.y = yToGet - y;
				var length:Number = dir.length;
				dir.normalize(speed * GV.elapsed);
				if (dir.length > length)
				{
					x += (xToGet - x) * 0.05;
					y += (yToGet - y) * 0.05;
				}
				else
				{
					x += dir.x;
					y += dir.y;
				}
			}
		}
		
		public function updateFromNetwork(s:String):void
		{
			var split:Array = s.split(",");
			if (isNaN(Number(split[0])) || isNaN(Number(split[1])))
				return;
			if (!added)
			{
				x = Number(split[0]);
				y = Number(split[1]);
				xToGet = x;
				yToGet = y;
				added = true;
				return;
			}
			xToGet = Number(split[0]);
			yToGet = Number(split[1]);
		}
	}

}