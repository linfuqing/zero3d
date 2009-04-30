package zerO.materials
{
	/**
	 * 渲染形材质,此类材质需在渲染前做一些事.
	 */
	public interface IRenderMaterial extends IMaterial
	{
		function doBeforeRender():void;
	}
}