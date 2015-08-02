package net.natpat 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Cell 
	{
		public static const SIZE:int = 40;
		
		
		public static const WALL:Cell = new Cell(0);
		public static const AIR:Cell = new Cell(1);
		
		private var id:int;
		
		public function Cell(id:int) 
		{
			this.id = id;
		}
		
		public function getID():int
		{
			return id;
		}
		
		public function render(bottomBuffer:BitmapData, topBuffer:BitmapData, x:int, y:int):void
		{
			if (this == WALL)
			{
				bottomBuffer.fillRect(new Rectangle(x * SIZE, y * SIZE + SIZE * 0.2, SIZE, SIZE * 0.8), 0xffaaaaaa);
				topBuffer.fillRect(new Rectangle(x * SIZE, y * SIZE - SIZE * 0.8, SIZE, SIZE), 0xff000000);
			}
			else
				bottomBuffer.fillRect(new Rectangle(x * SIZE, y * SIZE, SIZE, SIZE), 0xffffffff);
		}
		
		public static function getCellByID(id:int):Cell
		{
			if (id == 0) return WALL;
			if (id == 1) return AIR;
			return null;
		}
		
	}

}