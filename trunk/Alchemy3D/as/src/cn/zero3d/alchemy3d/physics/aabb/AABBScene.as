package cn.zero3d.alchemy3d.physics.aabb
{
	import AlchemyLib.container.Entity;
	
	import cn.zero3d.alchemy3d.physics.base.BasicScene;
	import cn.zero3d.alchemy3d.physics.math.AABB;
	
	public class AABBScene extends BasicScene
	{
		public function AABBScene(objects:Vector.<Entity>)
		{
			super(objects);
			
			_worldAABB = new Vector.<AABB>(objects.length);
		}
		
		public override function runObject(current:uint, target:uint):void
		{
			
		}
		
		public function getWorldAABB(index:uint):AABB
		{
			var aabb:AABB = _worldAABB[index] || ( _worldAABB[index] = new AABB() );
			
			_objects[index].getWorldAABB(aabb.min, aabb.max);
			
			return aabb;
		}
		
		protected override function update():void
		{
			var length:uint = _objects.length - _numObjects;
			
			_worldAABB = _worldAABB.concat( new Vector.<AABB>(length) );
		}
		
		protected var _worldAABB:Vector.<AABB>;
	}
}