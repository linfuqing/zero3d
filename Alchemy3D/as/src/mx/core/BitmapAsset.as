package mx.core
{
	// Workaround for Flash Builder warning while embedding images using the metadata tag. 
	//	"1017: The definition of base class BitmapAsset was not found."
	import flash.display.Bitmap;
	public class BitmapAsset extends Bitmap{}
}