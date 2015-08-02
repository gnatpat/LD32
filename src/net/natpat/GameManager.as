package net.natpat 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.drm.DRMPlaybackTimeWindow;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import net.natpat.gui.Button;
	import net.natpat.gui.InputBox;
	import net.natpat.particles.Emitter;
	import net.natpat.utils.Sfx;
	import flash.system.Security;
	
	import net.natpat.gui.Text;
	import net.natpat.gui.GuiManager
	import net.natpat.utils.Ease;
	import net.natpat.utils.Key;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GameManager 
	{
		public var socket:Socket = new Socket();
		
		public var serverText:Text = new Text(10, 10, "", 15, true, 0xffffff)
		
		/**
		 * Bitmap and bitmap data to be drawn to the screen.
		 */
		public var bitmap:Bitmap;
		public static var renderer:BitmapData;
		public var livingBuffer:BitmapData;
		
		public var map:Map;
		public var player:Player;
		
		public var players:Vector.<NetworkLiving>;
		
		public var inGame:Boolean = false;
		public var id:int;
		
		public function GameManager(stageWidth:int, stageHeight:int) 
		{
			GC.SCREEN_WIDTH = stageWidth;
			GC.SCREEN_HEIGHT = stageHeight;
			
			renderer = new BitmapData(stageWidth, stageHeight, false, 0x000000);
			
			bitmap = new Bitmap(renderer);
			
			GV.screen = renderer;
			
			GuiManager.add(serverText);
			serverText.text = "Connecting...";
			players = new Vector.<NetworkLiving>();
			
			//Attempt to connect to our node server...
			socket.addEventListener(Event.CONNECT, connected);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			socket.connect("192.168.1.159", 8124);
			
			//map = new Map(40, 40);
			livingBuffer = new BitmapData(GC.MAP_SIZE * Cell.SIZE, GC.MAP_SIZE * Cell.SIZE, true, 0);
		}
		
		public function startGame(map:Map):void
		{
			player = new Player(map);
			this.map = map;
			inGame = true;
			var timer:Timer = new Timer(1000 / GC.UPDATES_PER_SECOND, 0);
			timer.addEventListener(TimerEvent.TIMER, sendNewPosition);
			timer.start();
		}
		
		
		public function connected(e:Event):void
		{
			serverText.text = "Connected. Getting current game.\n";
		}
		
		public function onData(e:ProgressEvent):void
		{
			var data:String = socket.readUTFBytes(socket.bytesAvailable);
			var messages:Array = data.split('\n');
			//trace(messages);
			for each(var message:String in messages)
			{
				var type:String = message.charAt(0);
				trace(type);
				var values:String = message.slice(1);
				switch(type)
				{
					
					case "W":
						this.id = int(values);
						break;
					//Send a new map!
					case "S":
						var newMap:Map = new Map(GC.MAP_SIZE, GC.MAP_SIZE);
						var string:String = newMap.toNetworkString();
						
						socket.writeUTFBytes("M" + string + "\n");
						socket.flush();
						startGame(newMap);
						break;
						
					case "M":
						trace("Got a map!");
						var newMap:Map = Map.fromNetworkString(values);
						startGame(newMap);
						break;
					
					case "J":
						var newPlayer:NetworkLiving = new NetworkLiving(map, int(values));
						players.push(newPlayer);
						break;
					
					case "N":
						var id_:int = int(values);
						var newPlayer = new NetworkLiving(map, id_);
						players.push(newPlayer);
						break;
						
					case "U":
						var split:Array = values.split(":");
						var id:int = int(split[0]);
						var np:NetworkLiving = getPlayerByID(id);
						if (np != null)
						{
							np.updateFromNetwork(split[1]);
						}
						break;
						
					case "L":
						var np:NetworkLiving = getPlayerByID(int(values));
						if (np != null)
							players.splice(players.indexOf(np), 1);
						break;
				}
			}
		}
		
		public function onSecurityError(e:SecurityErrorEvent):void {
			serverText.text = "Security error. The policy server is probably down."
		}
		
		public function onIOError(e:IOErrorEvent):void
		{
			serverText.text = "Network Error. The server may be down."
			serverText.text += e.text;
		}
		
		public function render():void
		{	
			renderer.lock();
			
			renderer.fillRect(renderer.rect, 0xffffffff);
			
			if (inGame)
			{
				for (var ray:int = 0; ray < GC.NO_OF_RAYS; ray++)
				{
					var xRenderPos:int = ray * GC.RAY_WIDTH;
					var degAngle:Number = getAngleFromRay(ray) + player.getAngle();
					var angle:Number = degAngle * GV.RAD;
					var xStep:Number = Math.cos(angle);
					var yStep:Number = Math.sin(angle);
					
					if (xStep == 0) xStep = 0.0000001;
					if (yStep == 0) yStep = 0.0000001;
					
					var dist:Number = 0;
					var x:Number = player.getPos().x;
					var y:Number = player.getPos().y;
					
					var wallFound:Boolean = false;
					while (dist < GC.RAY_LENGTH)
					{
						var nextX:Number;
						if (xStep < 0) nextX = Math.floor((x - 0.000001) / Cell.SIZE) * Cell.SIZE;
						else 		   nextX = Math.ceil((x + Cell.SIZE) / Cell.SIZE) * Cell.SIZE;
						var nextY:Number;
						if (yStep < 0) nextY = Math.floor((y - 0.000001) / Cell.SIZE) * Cell.SIZE;
						else 		   nextY = Math.ceil((y + Cell.SIZE) / Cell.SIZE) * Cell.SIZE;
						
						var dx:Number = nextX - x;
						var dy:Number = nextY - y;
						
						var cellX:int, cellY:int;
						
						if (dx / xStep < dy / yStep)
						{
							var stepLength:Number = dx / xStep;
							dist += stepLength;
							x = nextX;
							y += stepLength * yStep;
							
							cellX = Math.floor(x / Cell.SIZE);
							cellY = Math.floor(y / Cell.SIZE);
							
							if (xStep < 0) cellX -= 1;
						}
						else
						{
							var stepLength:Number = dy / yStep;
							dist += stepLength;
							y = nextY;
							x += stepLength * xStep;
							
							cellX = Math.floor(x / Cell.SIZE);
							cellY = Math.floor(y / Cell.SIZE);
							
							if (yStep < 0) cellY -= 1;
						}
						
						if (map.getCell(cellX, cellY) == Cell.WALL)
						{
							wallFound = true;
							break;
						}
					}
					
					if (wallFound)
					{
						var wallHeight:Number = ((GC.RAY_LENGTH - dist) / GC.RAY_LENGTH) * GC.SCREEN_HEIGHT * Math.cos(getAngleFromRay(ray) * GV.RAD);
						renderer.fillRect(new Rectangle(xRenderPos, (GC.SCREEN_HEIGHT - wallHeight) / 2, GC.RAY_WIDTH, wallHeight), 0x000000);
					}
				}
			}
			
			GuiManager.render();
			
			renderer.unlock();
		}
		
		private function getAngleFromRay(ray:int):Number
		{
			return (((ray / GC.NO_OF_RAYS) * 2 - 1) * -GC.FOV);
		}
		
		public function update():void
		{
			GuiManager.update();
			
			if (inGame)
			{
				player.update();
				for each(var np:NetworkLiving in players)
				{
					np.update();
				}
			}
			
			Input.update();
		}
		
		private function getPlayerByID(id:int):NetworkLiving
		{
			for each(var np:NetworkLiving in players)
			{
				if (np.getID() == id)
					return np;
			}
			return null;
		}
		
		private function sendNewPosition(e:TimerEvent):void
		{
			if (player.shouldSendUpdate())
			{
				socket.writeUTFBytes("U" + player.toNetworkString() + "\n");
				socket.flush();
				player.sentUpdate();
			}
		}
		
	}

}