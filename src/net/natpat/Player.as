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
		
		public function Player(map:Map) 
		{
			super(map);
		}
		
		public function update():void
		{
			dir.x = 0;
			dir.y = 0;
			if (Input.keyDown(Key.W))
			{
				dir.y -= 1;
			}
			if (Input.keyDown(Key.S))
			{
				dir.y += 1;
			}
			if (Input.keyDown(Key.A))
			{
				dir.x -= 1;
			}
			if (Input.keyDown(Key.D))
			{
				dir.x += 1;
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
			angle += 180 * GV.elapsed;
		}
		
		override public function render(buffer:BitmapData):void
		{
			super.render(buffer);
		}
	}

}