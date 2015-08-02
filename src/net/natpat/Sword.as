package net.natpat 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class Sword 
	{
		
		private static var rot:RotationImage = new RotationImage(Assets.SWORD, 1, false);
		
		private var owner:Living;
		
		private var angle:Number;
		private var angleToGet:int;
		
		private static const ROT_SPEED:int = 480;
		
		private var swordBuffer:BitmapData;
		
		public function Sword(owner:Living) 
		{
			this.owner = owner;
			angle = 0;
			swordBuffer = new BitmapData(rot.width, rot.width, true, 0);
		}
		
		public function moveToAngle(angle:int):void
		{
			angle = angle % 360;
			this.angleToGet = angle;
		}
		
		public function update():void
		{
			if (int(angle) != angleToGet)
			{
				var dir:int;
				var diff:int = angle - angleToGet;
				if (diff > 0 && diff <= 180)
					dir = 1;
				else if (diff < 0 && diff <= -180)
					dir = -1;
				else if (diff > 180)
					dir = -1;
				else
					dir = 1;
				var delta:Number = ROT_SPEED * GV.elapsed;
				if ((angle + delta) * dir > angleToGet * dir)
					angle = angleToGet;
				else
					angle += delta;
					
				if (angle > 360)
					angle -= 360;
				if (angle < 0)
					angle += 360;
			}
		}
		
		public function render(buffer:BitmapData):void
		{
			swordBuffer.fillRect(swordBuffer.rect, 0);
			var m:Matrix = new Matrix;
			rot.angle = -angle;
			rot.render(0, 0, swordBuffer);
			m.translate(35, 0);
			m.rotate(angle / 180 * -Math.PI);
			//m.translate( -15, -5);//
			m.translate(owner.getPos().x, owner.getPos().y);
			buffer.draw(swordBuffer, m);
		}
		
		
		
	}

}