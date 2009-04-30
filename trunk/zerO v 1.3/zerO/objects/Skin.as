package zerO.objects
{
	import flash.geom.Matrix3D;
	
	import zerO.geom.Geometry;
	
	/**
	 * 骨骼,与普通节点不同.它是逆向变换.
	 */
	public class Skin extends DisplayObject3D
	{
		/**
		 * 构建新的骨骼.
		 */
		public function Skin(name:String=null, geometry:Geometry=null)
		{
			super(name, geometry);
		}
		
		/**
		 * 更新点集。
		 */
		override protected function updatePoints():void
		{
			updateChildren();
		}
		
		/**
		 * 字符化。
		 */
		override public function toString():String
		{
			return "Skin: " + name + super.toString();
		}
		
	}
}