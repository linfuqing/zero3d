package cn.zero3d.alchemy3d.physics.base
{
	import AlchemyLib.container.Entity;

	public class BasicScene
	{
		public function BasicScene(objects:Vector.<Entity>)
		{
			_objects = objects;
			
			_numObjects = _objects ? _objects.length : 0;
		}
		
		public function begin():Boolean
		{
			if(!_objects)
				return false;
			
			if(_numObjects != _objects.length)
			{
				update();
				
				_numObjects = _objects.length;
			}
			
			return true;
		}
		
		public function end(current:int = -1):Boolean
		{
			if(!_objects)
				return false;
			
			var i:uint;
			var j:uint;
			
			if(current >= 0)
			{
				for(i = 0; i < _numObjects; i ++)
				{
					if(i == current)
						continue;
					
					runObject(current, i);
				}
			}
			else
			{
				for(i = 0; i < _numObjects; i ++)
				{
					for(j = i + 1; j < _numObjects; j ++)
					{
						if(_objects[i] === _objects[j])
							continue;
						
						runObject(i, j);
					}
				}
			}
			
			return true;
		}
		
		public function runObject(current:uint, target:uint):void
		{
			
		}
		
		protected function update():void
		{
//			var length:uint = _objects.length;
//			for(var i:uint = _numObjects; i < length; i ++)
//				updateObjects(i);
		}
		
//		protected function updateObjects(index:uint):void
//		{
//			
//		}
		
		protected var _objects:Vector.<Entity>;
		//protected var _current:Entity;
		protected var _numObjects:uint;
	}
}