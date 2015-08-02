package net.natpat 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.natpat.utils.Key;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Player extends Living 
	{
		private var dir:Point = new Point;
		
		private var angle:Number = 0;
		private var rotSpeed:Number = 180;
		
		public function Player(map:Map) 
		{
			super(map);
		}
		
		public function update():void
		{
			if (Input.keyDown(Key.A))
			{
				angle += rotSpeed * GV.elapsed;
			}
			if (Input.keyDown(Key.D))
			{
				angle -= rotSpeed * GV.elapsed;
			}
			
			dir.x = 0;
			dir.y = 0;
			var radAngle = angle * GV.RAD;
			if (Input.keyDown(Key.W))
			{
				dir.x += Math.cos(radAngle);
				dir.y += Math.sin(radAngle);
			}
			if (Input.keyDown(Key.S))
			{
				dir.x -= Math.cos(radAngle);
				dir.y -= Math.sin(radAngle);
			}
			dir.normalize(speed * GV.elapsed);
			
			if (!dir.equals(GC.ZERO))
			{
				needToUpdate = true;
				x += dir.x;
				while (!canStand(x, y))
				{
					x += dir.x * -0.1;
				}
				y += dir.y;
				while (!canStand(x, y))
				{
					y += dir.y * -0.1;
				}
			}
		}
		
		public function getAngle():Number
		{
			return angle;
		}
		
		override public function render(buffer:BitmapData):void
		{
			super.render(buffer);
		}
	}

}