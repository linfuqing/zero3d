package
{
	import AlchemyLib.container.Entity;
	import AlchemyLib.external.Primitives;
	import AlchemyLib.geom.Mesh3D;
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
	import flash.text.TextFieldAutoSize;
	
	[SWF(width="1280",height="720",backgroundColor="#000000",frameRate="60")]
	public class TestViewport extends Basic
	{
		public function TestViewport(viewWidth:int=1280, viewHeight:int=720, fov:Number=90, near:Number=100, far:Number=5000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			viewport.backgroundColor = 0xffffffff;
			
			var bitmapData:BitmapData = new BitmapData(1024, 1024);
			bitmapData.perlinNoise(1024, 1024, 7, Math.random() * 1000, true, true, 7, true);
			
			var m:Material = new Material();
			m.ambient = new ColorTransform(0, 1, 1, 1);
			m.diffuse = new ColorTransform(1, 1, 1, 1);
			m.specular = new ColorTransform(1, 1, 1, 1);
			m.power = 0;
			m.doubleSide = true;
			
			object = new Primitives(m, new Texture(null, bitmapData) );
			
			object.toPlane(1.28, 0.72, 10, 10);
			
			scene.addChild(object);
			
			camera.z = -200;
			
			this.startRendering();
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			renderMode     = new Vector.<uint>();
			renderModeName = new Vector.<String>();
			
			renderMode.push(RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			renderMode.push(RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			renderMode.push(RenderMode.RENDER_WIREFRAME_TRIANGLE_32);
			
			renderModeName.push("TEXTRUE");
			renderModeName.push("COLOR");
			renderModeName.push("WIREFRAME");
			
			currentRenderMode = 0;

			text = new TextField();
			text.text = "Mode: WIREFRAME";
			text.x = 100;
			text.autoSize = TextFieldAutoSize.LEFT;
			addChild(text);
			
//			side = new TextField();
//			side.text = "1.28 * 0.72";
//			side.y = 100;
//			side.x = 100;
//			addChild(side);
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected override function onRenderTick(e:Event=null):void
		{
			super.onRenderTick(e);
			
			object.scale = Math.abs(mouseX - 640);
			
			//side.text = (1.28 * object.scale) + " * " + (0.72 * object.scale);
		}
		
		private function onClick(e:MouseEvent):void
		{
			object.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode[currentRenderMode % renderMode.length]);
			text.text = "Mode: " + renderModeName[currentRenderMode % renderModeName.length];
			
			currentRenderMode ++;
		}
		
		private var object:Primitives;
		private var currentRenderMode:uint;
		private var renderMode:Vector.<uint>;
		private var renderModeName:Vector.<String>;
		private var text:TextField;
		//private var side:TextField;
	}
}