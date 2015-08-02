package net.natpat 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import mx.core.EdgeMetrics;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Map 
	{
		
		private var width:int;
		private var height:int;
		
		private var data:Array;
		private var entityData:Array;
		private var topBuffer:BitmapData;
		private var bottomBuffer:BitmapData;
		
		private var seedUsed:int;
		
		public function Map(width:int, height:int, generate:Boolean = true) 
		{
			this.width = width;
			this.height = height;
			setUpData();
			if(generate)
				generateMap(Math.random() * int.MAX_VALUE);
		}
		
		private function setUpData():void
		{
			data = new Array(width);
			entityData = new Array(width);
			for (var x:int = 0; x < width; x++)
			{
				data[x] = new Array(height);
				entityData[x] = new Array(height);
				for (var y:int = 0; y < height; y++)
				{
					data[x][y] = Cell.WALL;
					entityData[x][y] = new Vector.<Living>();
				}
			}
		}
	
		public function setObjPos(obj:Living, x:Number, y:Number):void
		{
			
		}
		
		private var ROOM_VARIANCE:int = 5;
		private var ROOM_SIZE:int = 3;
		private var CORRIDOR_LENGTH = 2;
		private var CORRIDOR_VARIANCE = 4;
		private function generateMap(seed:int):void
		{
			this.seed = seed;
			seedUsed = seed;
			trace("Using seed: " + seed);
			var rooms:Array = new Array();
			
			//Add inital room
			var size:int = ROOM_SIZE + ROOM_VARIANCE + 1;
			rooms.push(clearRoom((width - size)/2, (height - size) / 2, size, size));
			
			var attempts = 0;
			
			while (attempts < 100)
			{
				attempts++;
				var type:Number = random();
				if (type < 0.6)
				{
					//Try placing a room
					var edge:Edge = getEdge(rooms);
					var width:int = random() * ROOM_VARIANCE + ROOM_SIZE;
					var height:int = random() * ROOM_VARIANCE + ROOM_SIZE;
					var x:int, y:int;
					switch(edge.dir) {
						case 0:
							x = edge.x - width;
							y = edge.y - height / 2;
							break;
						case 1:
							x = edge.x - width / 2;
							y = edge.y - height;
							break;
						case 2:
							x = edge.x + 1;
							y = edge.y - height / 2;
							break;
						case 3:
							x = edge.x - width / 2;
							y = edge.y + 1;
							break;
					}
					if (canPlaceRoom(x, y, width, height))
					{
						rooms.push(clearRoom(x, y, width, height));
						setCell(edge.x, edge.y, Cell.AIR);
						attempts = 0;
					}
				}
				else
				{
					var edge:Edge = getEdge(rooms);
					var x:int, y:int, width:int, height:int;
					var length:int = random() * CORRIDOR_VARIANCE + CORRIDOR_LENGTH;
					switch(edge.dir) {
						case 0:
							x = edge.x - length;
							y = edge.y;
							width = length;
							height = 1;
							break;
						case 1:
							x = edge.x;
							y = edge.y - length;
							width = 1;
							height = length;
							break;
						case 0:
							x = edge.x + 1;
							y = edge.y;
							width = length;
							height = 1;
							break;
						case 0:
							x = edge.x;
							y = edge.y + 1;
							width = 1;
							height = length;
							break;
					}
					if (canPlaceCorridor(x, y, width, height))
					{
						rooms.push(clearRoom(x, y, width, height));
						setCell(edge.x, edge.y, Cell.AIR);
						attempts = 0;
					}
				}
			}
			
			topBuffer = new BitmapData(this.width * Cell.SIZE, this.height * Cell.SIZE, true, 0x00000000);
			bottomBuffer = new BitmapData(this.width * Cell.SIZE, this.height * Cell.SIZE, true);
			render(bottomBuffer, topBuffer);
			
		}
		
		private function getEdge(rooms:Array):Edge
		{
			var index:int = random() * rooms.length;
			var room:Room = rooms[index];
			var side:int = random() * 4;
			switch(side)
			{
				//left
				case 0:
					return new Edge(room.left - 1, room.top + random() * room.height, 0);
				//top
				case 1:
					return new Edge(room.left + random() * room.width, room.top - 1, 1);
				//right
				case 2:
					return new Edge(room.left + room.width, room.top + random() * room.height, 2);
				case 3:
					return new Edge(room.left + random() * room.width, room.top + room.height, 3);
			}
			return null;
		}
		
		private function canPlaceRoom(left:int, top:int, width:int, height:int):Boolean
		{
			if (left < 0 || top < 0 || left + width >= this.width || top + height >= this.height)
				return false;
			width+=2;
			height += 2;
			left--;
			top--;
			for (var x:int = 0; x < width; x++)
				for (var y:int = 0; y < height; y++)
					if (getCell(x + left, y + top) != Cell.WALL)
						return false;
			return true;
		}
		
		private function canPlaceCorridor(left:int, top:int, width:int, height:int):Boolean
		{
			return canPlaceRoom(left, top, width, height);
		}
		
		private function clearRoom(left:int, top:int, width:int, height:int):Room
		{
			for (var x:int = 0; x < width; x++)
				for (var y:int = 0; y < height; y++)
					setCell(left + x, top + y, Cell.AIR);
			
			return new Room(left, top, width, height);
		}
		
		public function getCell(x:int, y:int):Cell
		{
			if (x < 0 || x >= width || y < 0 || y >= height)
				return Cell.WALL;
			return data[x][y];
		}
		
		private function setCell(x:int, y:int, cell:Cell):void
		{
			if (x < 0 || x >= width || y < 0 || y >= height)
				return;
			data[x][y] = cell;
		}
		
		public function getSpawnLocation():Point
		{
			return new Point(width / 2, height / 2);
		}
		
		public function render(bottomBuffer:BitmapData, topBuffer:BitmapData):void
		{
			for (var x:int = 0; x < width; x++)
				for (var y:int = 0; y < height; y++)
					getCell(x, y).render(bottomBuffer, topBuffer, x, y);
		}
		
		public function getTopBuffer():BitmapData
		{
			return topBuffer;
		}
		
		public function getBottomBuffer():BitmapData
		{
			return bottomBuffer;
		}
		
		public function toNetworkString():String
		{
			var string:String = "" + width + "*" + height + "*" + seedUsed;
			return string;
		}
		
		public static function fromNetworkString(string:String):Map
		{
			var pieces:Array = string.split("*", 3);
			var map:Map = new Map(int(pieces[0]), int(pieces[1]), false);
			map.generateMap(int(pieces[2]));
			return map;
		}
		
		private var seed:int = 777;

		private const MAX_RATIO:Number = -1 / int.MAX_VALUE;
		private const MIN_MAX_RATIO:Number = -MAX_RATIO;

		private function random():Number
		{
		   seed ^= (seed << 21);
		   seed ^= (seed >>> 35);
		   seed ^= (seed << 4);
		   if (seed < 0) return seed * MAX_RATIO;
		   return seed * MIN_MAX_RATIO;
		}
	}
}