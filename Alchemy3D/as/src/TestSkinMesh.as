package
{
	import AlchemyLib.container.Entity;
	import AlchemyLib.external.DAE;
	import AlchemyLib.external.MD2;
	import AlchemyLib.render.Material;
	import AlchemyLib.render.RenderMode;
	import AlchemyLib.render.Texture;
	import AlchemyLib.tools.Basic;
	import AlchemyLib.tools.FPS;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	[SWF(width="800",height="535",backgroundColor="#000000",frameRate="60")]
	public class TestSkinMesh extends Basic
	{
		[Embed(source="asset/girl_test/girl.jpg",mimeType="application/octet-stream")]
		private var daeFile:Class;
		
		[Embed(source="asset/girl_test/girl_body.jpg")]
		private var body:Class;
		
		[Embed(source="asset/girl_test/girl_skirt.jpg")]
		private var skirt:Class;
		
		[Embed(source="asset/girl_test/girl_shoe.jpg")]
		private var shoe:Class;
		
		[Embed(source="asset/girl_test/girl_hair.png")]
		private var hair:Class;
		
		[Embed(source="asset/girl_test/girl_face.jpg")]
		private var face:Class;
		
		[Embed(source="asset/md2/lv2_test3.md2",mimeType="application/octet-stream")]
		private var md2File:Class;
		
		[Embed(source="asset/md2/ground1.jpg")]
		private var texture:Class;

		public function TestSkinMesh(viewWidth:int=800, viewHeight:int=535, fov:Number=90, near:Number=100, far:Number=5000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			objects = new Vector.<Entity>();

			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			viewport.backgroundColor = 0xffffffff;
			
			camera.z = - 300;
			
			textureData =  new Vector.<BitmapData>();
			textureData.push( ( (new body) as Bitmap ).bitmapData );
			textureData.push( ( (new hair) as Bitmap ).bitmapData );
			textureData.push( ( (new shoe) as Bitmap ).bitmapData );
			textureData.push( ( (new skirt) as Bitmap ).bitmapData );
			textureData.push( ( (new face) as Bitmap ).bitmapData );
			
			textureMap = new Vector.<String>();
			textureMap.push( "_1_-_Default" );
			textureMap.push( "_2_-_Default" );
			textureMap.push( "_5_-_Default" );
			textureMap.push( "_6_-_Default" );
			textureMap.push( "Material__232" );
			
//			var m:Material = new Material();
//			m.ambient = new ColorTransform(0, 1, 1, 1);
//			m.diffuse = new ColorTransform(1, 1, 1, 1);
//			m.specular = new ColorTransform(1, 1, 1, 1);
//			m.power = 0;
//
//			md2 = new MD2(m, new Texture( ( (new texture) as Bitmap ).bitmapData ), RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
//			md2.parse(new md2File);
//			md2.rotationX -= 135;
//			md2.z = 200;
//			scene.addChild(md2);
			
			this.startRendering();
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			text = new TextField();
			text.x = 100;
			text.text = "Dae: 0";
			
			xml = XML(new daeFile);
			
			addChild(text);
		}
		
		private function onClick(e:MouseEvent):void
		{
			dae = new DAE();
			//dae.load("asset/r01.dae");
			dae.parse(xml);
			dae.setBitmapData(textureData, textureMap);
			dae.scale = 5;
			
			objects.push(dae);
			
			scene.addChild(dae);
			
			text.text = "Dae: " + objects.length;
		}
		
		protected override function onRenderTick(e:Event=null):void
		{
			super.onRenderTick(e);
			
			for(var i:uint = 0; i < objects.length; i ++)
				objects[i].rotationY ++;
		}
		
		private var textureData:Vector.<BitmapData>;
		private var textureMap:Vector.<String>;
		private var objects:Vector.<Entity>;
		private var dae:DAE;
		private var md2:MD2;
		private var text:TextField;
		private var xml:XML;
	}
}