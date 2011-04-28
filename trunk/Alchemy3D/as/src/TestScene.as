package
{
	import AlchemyLib.animation.SkeletalAnimation;
	import AlchemyLib.container.Entity;
	import AlchemyLib.events.LoadEvent;
	import AlchemyLib.external.A3DS;
	import AlchemyLib.external.DAE;
	import AlchemyLib.external.Primitives;
	import AlchemyLib.render.Material;
	import AlchemyLib.render.RenderMode;
	import AlchemyLib.render.Texture;
	import AlchemyLib.tools.Basic;
	import AlchemyLib.tools.FPS;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	[SWF(width="800",height="535",backgroundColor="#000000",frameRate="60")]
	public class TestScene extends Basic
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
		
		public function TestScene(viewWidth:int=800, viewHeight:int=535, fov:Number=50, near:Number=100, far:Number=10000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			objects = new Vector.<Entity>();
			
			viewport.backgroundColor = 0xffffffff;
			
			camera.x = 0;
			camera.y = 0;
			camera.z = 0;

			var m:Material = new Material(null,
				new ColorTransform(0.0, 1.0, 0.0) );
			terrain = new Primitives(m, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			terrain.toPlane(1000, 1000, 1, 1);
			terrain.rotationX += 90;
			terrain.y = - 100;
			//terrain.mesh.octreeDepth = 3;
			scene.addChild(terrain);
			
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
			
			xml = XML(new daeFile);
			
			dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			dae.parse(xml, true, null);
			dae.setBitmapData(textureData, textureMap);
			//dae.rotationZ += 180;
			dae.y = - 100;
			dae.x = 0;
			dae.z = 500;
			//dae = new DAE(false, false, 1, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			//dae.load("asset/春节导出/newyear.DAE");
			
			textureList = dae.texture;
			materialList = dae.material;
			animationList = dae.animation;
			
			objects.push(dae);
			
			scene.addChild(dae);
			
			var a3ds:A3DS = new A3DS(RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			a3ds.load("asset/colonne/colonne_vip2.3DS");
			scene.addChild(a3ds);
			
			key = new Vector.<Boolean>(8);
			key[0] = key[1] = key[2] = key[3] = key[4] = key[5] = key[6] = key[7] = false;
			
			mouseStartPoint = new Point();
			mouseEndPoint = new Point();
			
			forwardSpeed = upSpeed = rightSpeed = 0;
			
			this.startRendering();

			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			text = new TextField();
			text.x = 100;
			text.text = "模型数量: 1  \n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n";
			text.textColor = 0xffff0000;
			text.autoSize = TextFieldAutoSize.LEFT;

			addChild(text);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			//stage.addEventListener(MouseEvent.CLICK, onClick);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			mouseStartPoint.x = mouseX;
			mouseStartPoint.y = mouseY;
			
			mouseBegin = true;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			mouseBegin = false;
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			forwardSpeed = e.delta * 2;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 87:
					//camera.eye.forward(10);
					key[0] = true;
					break;
				
				case 65:
					key[1] = true;
					//camera.rotationY --;
					break;
				
				case 68:
					key[2] = true;
					//camera.rotationY ++;
					break;
				
				case 83:
					key[3] = true;
					//camera.eye.forward(- 10);
					break;
				
//				case Keyboard.UP:
//					key[4] = true;
//					break;
//				
//				case Keyboard.DOWN:
//					key[5] = true;
//					break;
//				
//				case Keyboard.LEFT:
//					key[6] = true;
//					break;
//				
//				case Keyboard.RIGHT:
//					key[7] = true;
//					break;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 87:
					//camera.eye.forward(10);
					key[0] = false;
					break;
				
				case 65:
					key[1] = false;
					//camera.rotationY --;
					break;
				
				case 68:
					key[2] = false;
					//camera.rotationY ++;
					break;
				
				case 83:
					key[3] = false;
					//camera.eye.forward(- 10);
					break;
				
//				case Keyboard.UP:
//					key[4] = false;
//					break;
//				
//				case Keyboard.DOWN:
//					key[5] = false;
//					break;
//				
//				case Keyboard.LEFT:
//					key[6] = false;
//					break;
//				
//				case Keyboard.RIGHT:
//					key[7] = false;
//					break;
				
				case Keyboard.ENTER:
					dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_BILERP_TRIANGLE_INVZB_32);
					//dae.load("asset/girl_test/girl.jpg");
					dae.parse(xml, true, null, materialList, textureList);
					dae.setupSkeletalAnimation(animationList);
					//dae.rotationZ += 180;
					dae.y = - 100;
					dae.x = Math.random() * 1000 - 500;
					dae.z = Math.random() * 1000 - 500;
					
					objects.push(dae);
					
					scene.addChild(dae);
					
					text.text = "模型数量: " + objects.length + "\n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n";
					break;
			}
		}
		
		protected override function onRenderTick(e:Event=null):void
		{
			super.onRenderTick(e);
			
			//dae.rotationY ++;
			
			if(key[0])
				//camera.eye.up(-10);
				upSpeed = - 10;
			
			if(key[1])
				//camera.eye.right(-10);
				rightSpeed = - 10;
			
			if(key[2])
				//camera.eye.right(10);
				rightSpeed = 10;
			
			if(key[3])
				//camera.eye.up(10);
				upSpeed = 10;
			
//			if(key[4])
//				camera.rotationX --;
//			
//			if(key[5])
//				camera.rotationX ++;
//			
//			if(key[6])
//				camera.eye.right(-10);
//			
//			if(key[7])
//				camera.eye.right(10);
			
			camera.eye.right(rightSpeed);
			camera.eye.up(upSpeed);
			camera.eye.forward(forwardSpeed);
			
			rightSpeed *= friction;
			upSpeed *= friction;
			forwardSpeed *= friction;

			if(mouseBegin)
			{
				mouseEndPoint.x = mouseX;
				mouseEndPoint.y = mouseY;
			}
			
			var point:Point = mouseEndPoint.subtract(mouseStartPoint);
				
			camera.rotationX += point.y * mouseMoveX;
			camera.rotationY += point.x * mouseMoveY;
				
			point.x *= mouseInterpolation;
			point.y *= mouseInterpolation;
				
			mouseStartPoint = mouseStartPoint.add(point);
		}

		private var textureData:Vector.<BitmapData>;
		private var textureMap:Vector.<String>;
		
		private var textureList:Vector.<Texture>;
		private var materialList:Vector.<Material>;
		private var animationList:Vector.<SkeletalAnimation>;
		
		private var objects:Vector.<Entity>;
		private var dae:DAE;
		private var loader:URLLoader;
		private var text:TextField;
		private var xml:XML;
		private var terrain:Primitives;
		
		private var key:Vector.<Boolean>;
		
		private var mouseStartPoint:Point;
		private var mouseEndPoint:Point;
		private var mouseBegin:Boolean;
		private var mouseInterpolation:Number = 0.05;
		private var mouseMoveX:Number = 0.01;
		private var mouseMoveY:Number = 0.01;
		
		private var forwardSpeed:Number;
		private var upSpeed:Number;
		private var rightSpeed:Number;
		
		private var friction:Number = 0.95;
	}
}