package
{
	import AlchemyLib.animation.SkeletalAnimation;
	import AlchemyLib.base.Pointer;
	import AlchemyLib.container.Entity;
	import AlchemyLib.events.LoadEvent;
	import AlchemyLib.external.A3DS;
	import AlchemyLib.external.DAE;
	import AlchemyLib.external.Primitives;
	import AlchemyLib.geom.Mesh3D;
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
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	import lattice.LatticeMap;
	import lattice.LatticeMap3D;
	import lattice.LatticeObject;
	
	[SWF(width="800",height="535",backgroundColor="#000000",frameRate="60")]
	public class TestAABB extends Basic
	{
//		[Embed(source="asset/girl_test/girl.jpg",mimeType="application/octet-stream")]
//		private var daeFile:Class;
//		
//		[Embed(source="asset/girl_test/girl_body.jpg")]
//		private var body:Class;
//		
//		[Embed(source="asset/girl_test/girl_skirt.jpg")]
//		private var skirt:Class;
//		
//		[Embed(source="asset/girl_test/girl_shoe.jpg")]
//		private var shoe:Class;
//		
//		[Embed(source="asset/girl_test/girl_hair.png")]
//		private var hair:Class;
//		
//		[Embed(source="asset/girl_test/girl_face.jpg")]
//		private var face:Class;
		
		public function TestAABB(viewWidth:int=800, viewHeight:int=535, fov:Number=50, near:Number=100, far:Number=5000)
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
			terrain.toPlane(640, 640, 10, 10);
			terrain.rotationX += 90;
			terrain.y = - 320;
			//terrain.mesh.octreeDepth = 3;
			scene.addChild(terrain);
			
			initLattice();
			initFurniture();
			addFurniture();
//			textureData =  new Vector.<BitmapData>();
//			textureData.push( ( (new body) as Bitmap ).bitmapData );
//			textureData.push( ( (new hair) as Bitmap ).bitmapData );
//			textureData.push( ( (new shoe) as Bitmap ).bitmapData );
//			textureData.push( ( (new skirt) as Bitmap ).bitmapData );
//			textureData.push( ( (new face) as Bitmap ).bitmapData );
//			
//			textureMap = new Vector.<String>();
//			textureMap.push( "_1_-_Default" );
//			textureMap.push( "_2_-_Default" );
//			textureMap.push( "_5_-_Default" );
//			textureMap.push( "_6_-_Default" );
//			textureMap.push( "Material__232" );
//			
//			xml = XML(new daeFile);
			
			//dae = new DAE(true, true, 1, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			//dae.parse(xml, true, null);
			//dae.setBitmapData(textureData, textureMap);
			//dae.load("asset/chest02.DAE");
			//dae.addEventListener(Event.COMPLETE, onLoadComplete);
			//dae.rotationZ += 180;
			//dae.y = - 100;
			//dae.x = 0;
			//dae.z = 500;
			//dae = new DAE(false, false, 1, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			//dae.load("asset/春节导出/newyear.DAE");
			//dae.visible = false;
			//textureList = dae.texture;
			//materialList = dae.material;
			//animationList = dae.animation;
			//geometryList = dae.geometry;
			
			//objects.push(dae);
			
			//scene.addChild(dae);
			
			//var a3ds:A3DS = new A3DS(RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			//a3ds.load("asset/colonne/colonne_vip2.3DS");
			//scene.addChild(a3ds);
			
			key = new Vector.<Boolean>(8);
			key[0] = key[1] = key[2] = key[3] = key[4] = key[5] = key[6] = key[7] = false;
			
			mouseStartPoint = new Point();
			mouseEndPoint = new Point();
			
			forwardSpeed = upSpeed = rightSpeed = 0;
			
			this.startRendering();
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			text = new TextField();
			text.text = "模型数量: 1  \n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n";
			text.x = 100;
			text.textColor = 0xffff0000;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(text);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function initFurniture():void
		{
			furniture = new Vector.<Furniture>();
			furniture.push( new Furniture( "asset/家具比例修改/床/bed_01/bed_01.dae", new Vector3D(13.5, 31, 7.5), new Vector3D(-13.5, -0, -7.5) ) );
			furniture.push( new Furniture( "asset/家具比例修改/床/bed_02/bed_02.dae", new Vector3D(11, 31, 6), new Vector3D(-11, -0, -6) ) );
			furniture.push( new Furniture( "asset/家具比例修改/杯具/cup/cup.dae", new Vector3D(1, 2, 0.5), new Vector3D(-1, -0, -0.5) ) );
			furniture.push( new Furniture( "asset/家具比例修改/杯具/cup_02/cup_02.dae", new Vector3D(1, 2, 1), new Vector3D(-1, -0, -1) ) );
			furniture.push( new Furniture( "asset/家具比例修改/柜子/chest_01/chest_1.dae", new Vector3D(14, 13, 17.5), new Vector3D(-14, -0, -17.5) ) );
			furniture.push( new Furniture( "asset/家具比例修改/柜子/chest_02/chest_2.dae", new Vector3D(12, 13, 16.5), new Vector3D(-12, -0, -16.5) ) );
		}
		
		private function onLoadComplete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			if(objects.length == 1)
			{
				textureList = dae.texture;
				materialList = dae.material;
				animationList = dae.animation;
				geometryList = dae.geometry;
			}
			
//			scene.addChild(dae);
//			
//			objects.push(dae);
//			
//			latticeObject.push(new LatticeObject);
//			
//			//var min:Vector3D = currentfurniture.min.clone();
//			//var max:Vector3D = currentfurniture.max.clone();
//			
//			//min.scaleBy(1);
//			//max.scaleBy(1);
//			
//			//min.y = min.z + (min.y = min.z);
//			//max.y = max.z + (max.y = max.z);
//			
//			var min:Vector3D = new Vector3D();
//			var max:Vector3D = new Vector3D();
//			
//			dae.getAABB(min, max);
//			
//			var y:Number;
//			
//			y     = min.y;
//			min.y = min.z;
//			min.z = y;
//			
//			y     = max.y;
//			max.y = max.z;
//			max.z = y;
//			
//			latticeMap.fillObject(latticeObject[latticeObject.length - 1], min, max);
//			
//			while(true)
//				if( latticeMap.moveTo3D(latticeObject[latticeObject.length - 1], Math.random() * 1280 - 640, 0, Math.random() * 1280 - 640) )
//					break;
//			
//			var point:Vector3D = new Vector3D();
//			
//			latticeMap.getObjectPosition3D(point, latticeObject[latticeObject.length - 1], true);
//			
//			dae.x = point.x;
//			dae.y = point.y;
//			dae.z = point.z;
//			
//			dae = objects[0] as DAE;
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
			if(key[4])
			{
				var length:uint = geometryList.length;
				for(var i:uint = 0; i < length; i ++)
					if(geometryList[i].isHit)
						break;
				
				if(i != length)
				{
					beginMousePosition = viewport.getWorldPositionFromScreen(mouseX, mouseY);
					beginDaePosition   = dae.position.clone();
					
					beginDepth = camera.eye.worldPosition.subtract(beginMousePosition).length;
				}
			}
			else
			{
				mouseStartPoint.x = mouseX;
				mouseStartPoint.y = mouseY;
				
				mouseBegin = true;
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			beginMousePosition = null;
			beginDaePosition = null;
			
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
				
				case Keyboard.SHIFT:
					key[4] = true;
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
				
				case Keyboard.SHIFT:
					key[4] = false;
					break;
				
				case Keyboard.ENTER:
//					dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
//					//dae.load("asset/girl_test/girl.jpg");
//					dae.parse(xml, true, null, materialList, textureList);
//					dae.setupSkeletalAnimation(animationList);
//					//dae.rotationZ += 180;
//					dae.y = - 100;
//					//dae.x = Math.random() * 1000 - 500;
//					//dae.z = Math.random() * 1000 - 500;
//					
//					latticeObject.push(new LatticeObject);
//					
//					var max:Vector3D = new Vector3D(50, 200, 50, 1);
//					var min:Vector3D = new Vector3D(-50,0,-50,1);
//					
//					//dae.getAABB(min, max);
//					
//					latticeMap.fillObject(latticeObject[latticeObject.length - 1], min, max);
//					
//					while( !latticeMap.moveTo3D(latticeObject[latticeObject.length - 1], Math.random() * 1000 - 500, - 100, Math.random() * 1000 - 500) );
//					
//					var point:Vector3D = new Vector3D();
//					
//					latticeMap.getObjectPosition3D(point, latticeObject[latticeObject.length - 1], true);
//					
//					dae.x = point.x;
//					dae.y = point.y;
//					dae.z = point.z;
//					
//					objects.push(dae);
//					
//					scene.addChild(dae);
//					
//					dae = objects[0] as DAE;
					addFurniture();
					
					text.text = "模型数量: " + objects.length + "\n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n";
					
					break;
				
				case Keyboard.END:
					//dae.visible = !dae.visible;
					trace(latticeMap);
					
					break;
				case Keyboard.BACKSPACE:
					var matrix:Matrix3D = new Matrix3D();
					matrix.appendRotation(90, Vector3D.Y_AXIS);
					
					if( latticeMap.rotateTo3D(latticeObject[0], matrix) )
						dae.rotationY += 90;
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
			
			
//			var length:uint = objects.length;
//			for(var i:uint = 0; i < length; i ++)
//			{
//				objects.
//			}
			
			if(beginMousePosition && beginDaePosition)
			{
				var position:Vector3D = viewport.getWorldPositionFromScreen(
					mouseX, mouseY, 
					beginDepth, false);
				
				if(position)
				{
					position = beginDaePosition.add( position.subtract(beginMousePosition) );
					
					if( latticeMap.moveTo3D(latticeObject[0], position.x, position.y, position.z) )
					{
						latticeMap.getObjectPosition3D(position, latticeObject[0], false);
						
						dae.x = position.x;
						dae.y = position.y;
						dae.z = position.z;
						
						//trace(latticeObject[0].x, latticeObject[0].y, latticeObject[0].z);
						//trace(latticeMap);
					}
					
					//dae.position = position;
				}
				
				//dae.y = position.y;
			}
		}
		
		private function initLattice():void
		{
			latticeMap = new LatticeMap3D(6, 6, 6, 640, 640, 640, - 320, - 320, - 320);
			latticeObject = new Vector.<LatticeObject>();
			//latticeObject.push(new LatticeObject);
			
			//var max:Vector3D = new Vector3D(50, 200, 50, 1);
			//var min:Vector3D = new Vector3D(-50,0,-50,1);
			
			//dae.getAABB(min, max);
			
			//latticeMap.fillObject(latticeObject[0], min, max);
		}
		
		private function addFurniture():void
		{
			var currentfurniture:Furniture = furniture[ uint( furniture.length * Math.random() )];//objects.length ? furniture[ uint( furniture.length * Math.random() )] : furniture[2];
			
			dae = new DAE(true, true, 1, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			dae.addEventListener(Event.COMPLETE, onLoadComplete);
			dae.load(currentfurniture.name);
			
			scene.addChild(dae);
			
			objects.push(dae);
			
			latticeObject.push(new LatticeObject);
			
			var min:Vector3D = currentfurniture.min.clone();
			var max:Vector3D = currentfurniture.max.clone();
			
			min.scaleBy(10);
			max.scaleBy(10);
			
			var y:Number;
			
			y     = min.y;
			min.y = min.z;
			min.z = y;
			
			y     = max.y;
			max.y = max.z;
			max.z = y;
			
			max.y = max.y - min.y;
			min.y = 0;
			
			max.z = (max.z + min.z) * 0.5;
			min.z = -max.z;
			
			latticeMap.fillObject(latticeObject[latticeObject.length - 1], min, max);
			
			while(true)
				if( latticeMap.moveTo3D(latticeObject[latticeObject.length - 1], Math.random() * 640 - 320, Math.random() * 640 - 320, Math.random() * 640 - 320) )
					break;
			
			var point:Vector3D = new Vector3D();
			
			latticeMap.getObjectPosition3D(point, latticeObject[latticeObject.length - 1], false);
			
			dae.x = point.x;
			dae.y = point.y;
			dae.z = point.z;
			
			dae = objects[0] as DAE;
			
			//trace(latticeMap);
		}
		
		private var textureData:Vector.<BitmapData>;
		private var textureMap:Vector.<String>;
		
		private var textureList:Vector.<Texture>;
		private var materialList:Vector.<Material>;
		private var animationList:Vector.<SkeletalAnimation>;
		private var geometryList:Vector.<Mesh3D>;
		
		private var objects:Vector.<Entity>;
		private var dae:DAE;
		private var loader:URLLoader;
		private var text:TextField;
		private var xml:XML;
		private var terrain:Primitives;
		
		private var key:Vector.<Boolean>;
		
		private var beginMousePosition:Vector3D;
		private var beginDaePosition:Vector3D;
		private var beginDepth:Number;
		
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
		
		private var latticeMap:LatticeMap3D;
		private var latticeObject:Vector.<LatticeObject>;
		
		private var furniture:Vector.<Furniture>;
	}
}
import flash.geom.Vector3D;

class Furniture
{
	public var max:Vector3D;
	public var min:Vector3D;
	
	public var name:String;
	
	public function Furniture(name:String, max:Vector3D, min:Vector3D)
	{
		this.name = name;
		this.max  = max;
		this.min  = min;
	}
}