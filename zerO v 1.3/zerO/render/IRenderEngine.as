package zerO.render
{
	import zerO.utils.INameSetter;
	
	public interface IRenderEngine extends INameSetter
	{
		function render():void;
		function get numRender():uint;
	}
}