package cn.zero3d.alchemy3d.physics.aabb
{
	import AlchemyLib.container.Entity;
	
	import cn.zero3d.alchemy3d.physics.math.AABB;
	
	import flash.geom.Vector3D;
	
	public class BasicAABBScene extends AABBScene
	{
		public function BasicAABBScene(objects:Vector.<Entity>)
		{
			super(objects);
			
			preValue      = new Vector.<Number>(objects.length);
			hitValue      = new Vector.<Number>(objects.length);
			ishit         = new Vector.<Boolean>(objects.length);
			hitPosition   = new Vector.<Vector3D>(objects.length);
		}
		
		public override function begin():Boolean
		{
			if( !super.begin() )
				return false;

			return true;
		}
		
		public override function end(current:int=-1):Boolean
		{
			var i:uint;
			for(i = 0; i < _numObjects; i ++)
			{
				preValue[i] = hitValue[i];
				hitValue[i] = 0;
			}
			
			if( !super.end(current) )
				return false;
			
			for(i = 0; i < _numObjects; i ++)
			{
				if(ishit[i])
				{
					if(hitValue[i])
					{
						if(hitValue[i] < preValue[i])
							_objects[current].position = hitPosition[current];
					}
					else
					{
						ishit[current] = false;
						hitPosition[current] = null;
					}
				}
			}
			
			return true;
		}
		
		public override function runObject(current:uint, target:uint):void
		{
			var currentAABB:AABB = getWorldAABB(0);
			var targetAABB :AABB = getWorldAABB(1);
			
			_objects[current].getWorldAABB(currentAABB.min, currentAABB.max);
			_objects[target ].getWorldAABB( targetAABB.min,  targetAABB.max);
			
			if(ishit[current])
			{
				if( currentAABB.hit(targetAABB) )
					hitValue[current] += currentAABB.getDistanceTo(targetAABB);
			}
			else
			{
				ishit[current] = currentAABB.hit(targetAABB);
				
				if(ishit[current])
				{
					hitPosition[current] = _objects[current].position.clone();
					
					hitValue[current] = currentAABB.getDistanceTo(targetAABB);
				}
			}
		}
		
		public override function getWorldAABB(index:uint):AABB
		{
			var aabb:AABB = _worldAABB[index] || ( _worldAABB[index] = new AABB() );
			
			return aabb;
		}
		
		protected override function update():void
		{
			super.update();
			
			var length:uint = _objects.length - _numObjects;
			
			preValue      = preValue.concat( new Vector.<Number>(length) );
			hitValue      = hitValue.concat( new Vector.<Number>(length) );
			ishit         = ishit.concat( new Vector.<Boolean>(length) );
			hitPosition   = hitPosition.concat( new Vector.<Vector3D>(length) );
		}
		
		private var preValue:Vector.<Number>;
		private var hitValue:Vector.<Number>;
		private var ishit:Vector.<Boolean>;
		private var hitPosition:Vector.<Vector3D>;
	}
}