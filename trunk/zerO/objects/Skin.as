package zerO.objects
{
	import flash.geom.Vector3D;
	
	import zerO.geom.Geometry;
	
	/**
	 * 骨骼,与普通显示对象不同.它是逆向变换.
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

		
	}
}