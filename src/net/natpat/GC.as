package net.natpat 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GC 
	{
		
		public static var SCREEN_WIDTH:int;
		
		public static var SCREEN_HEIGHT:int;
	
		public static const ZERO:Point = new Point(0, 0);
		
		public static const MAP_SIZE:int = 60;
		
		public static const UPDATES_PER_SECOND:int = 10;
			
		public static const RAY_WIDTH:int = 20;
		
		public static const NO_OF_RAYS:Number = 700 / RAY_WIDTH;
		
		public static const FOV:int = 30;
		
		public static const RAY_LENGTH:Number = 800;
	}

}