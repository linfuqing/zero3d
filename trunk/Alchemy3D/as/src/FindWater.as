package
{
	import AlchemyLib.animation.SkeletalAnimation;
	import AlchemyLib.base.Library;
	import AlchemyLib.container.Entity;
	import AlchemyLib.events.LoadEvent;
	import AlchemyLib.external.DAE;
	import AlchemyLib.external.Primitives;
	import AlchemyLib.fog.Fog;
	import AlchemyLib.geom.Mesh3D;
	import AlchemyLib.lights.Light3D;
	import AlchemyLib.lights.LightType;
	import AlchemyLib.render.Material;
	import AlchemyLib.render.RenderMode;
	import AlchemyLib.render.Texture;
	import AlchemyLib.terrain.MeshTerrain;
	import AlchemyLib.tools.Basic;
	import AlchemyLib.tools.FPS;
	import AlchemyLib.view.Camera3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="60")]
	public class FindWater extends Basic
	{
		[Embed(source="asset/girl_test/girl.jpg",mimeType="application/octet-stream")]
		private var daeFile:Class;
		
		[Embed(source="asset/girl_test/girl_body.jpg")]
		private var body:Class;
		
		[Embed(source="asset/girl_test/girl_skirt.jpg")]
		private var skirt:Class;
		
		[Embed(source="asset/girl_test/girl_shoe.jpg")]
		private var shoe:Class;
		
		[Embed(source="asset/girl_test/girl_hair.jpg")]
		private var hair:Class;
		
		[Embed(source="asset/girl_test/girl_face.jpg")]
		private var face:Class;
		
		[Embed(source="asset/water2.png")]
		private var waterTexture:Class;
		
		[Embed(source="asset/skin01.jpg")]
		private var terrainTexture:Class;
		
		public function FindWater(viewWidth:int=640, viewHeight:int=480, fov:Number=90, near:Number=100, far:Number=5000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			init();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//stopRendering();
		}
		
		private function init():void
		{
			objects = new Vector.<Entity>();
			
			viewport.backgroundColor = 0xffffffff;
			fog = new Fog(new ColorTransform(1, 1, 1, 1), 800, 3000, 1, Fog.FOG_LINEAR);
			scene.addFog(fog);
			
			camera.x = 0;
			camera.y = 0;
			camera.z = 0;
			camera.isUVN = true;
			camera.eye.terrainTrace = Entity.TERRAIN_TRACE_BOUNDARY;
			camera.eye.setLocalAABB( new Vector3D(-100, -300, -100), new Vector3D(100, 300, 100) );
			
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
			
			dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_TRIANGLE_FSINVZB_32);
			dae.parse(xml, true, null);
			dae.setBitmapData(textureData, textureMap);
			//dae.rotationZ += 180;
			dae.y = - 100;
			dae.x = 0;
			dae.z = 500;
			dae.terrainTrace = Entity.TERRAIN_TRACE_FIXED_HEIGHT;
			//dae.setLocalAABB(new Vector3D(0, -10, 0), new Vector3D(1, 50, 1));
			objects.push(dae);
			
			scene.addChild(dae);
			
			textureList = dae.texture;
			materialList = dae.material;
			animationList = dae.animation;
			//geometryList = dae.geometry;
			
			var i:uint;
			for(i = 0; i < textureList.length; i ++)
				textureList[i].perspectiveDist = 0;
			
			//for(i = 0; i< geometryList.length; i ++)
			//	geometryList[i].lightEnable = true;
			
			var m:Material = new Material(null,
				new ColorTransform(.2, .2, .2, 0),
				new ColorTransform(.6, .6, .6, 0.6),
				new ColorTransform(.6, .6, .6, 1),
				new ColorTransform(0, 0, 0, 1) );
			
			var w:Texture = new Texture(null, ( (new waterTexture) as Bitmap ).bitmapData);
			//w.perspectiveLPDist = 5000;
			water = new Primitives(m, w, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_ALPHA_32);
			water.toPlane(10000, 10000, 50, 50);
			water.mesh.octreeDepth = 2;
			water.mesh.fogEnable = true;
			water.mesh.lightEnable = true;
			//water.mesh.texScaleX = .5;
			//water.mesh.texScaleY = .5;
			water.mesh.addressMode = Mesh3D.ADDRESS_MODE_WRAP;
			water.rotationX = 90;
			water.y = -200;
			viewport.scene.addChild(water);
			
			enbleAlpha = true;
			//viewport.alphaMixed = true;
			var t:Texture = new Texture(null, ( (new terrainTexture) as Bitmap ).bitmapData);
			//t.perspectiveDist = 5000;
			terrain = new MeshTerrain(null, m, t, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			terrain.buildOn(40000, 40000, 10000, 1);
			//terrain.mesh.lightEnable = true;
			terrain.mesh.octreeDepth = 3;
			//terrain.mesh.texScaleX = 5;
			//terrain.mesh.texScaleY = 5;
			terrain.mesh.useMipmap = true;
			terrain.mesh.mipDist = 1000;
			terrain.mesh.addressMode = Mesh3D.ADDRESS_MODE_WRAP;
			terrain.mesh.fogEnable = true;
			
			viewport.scene.addChild(terrain);
			
			renderMode = RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32;
			enbleFog = true;
			
			var m1:Material = new Material();
			m1.ambient = new ColorTransform(.2, .2, .2, 1);
			m1.diffuse = new ColorTransform(.6, .6, .6, 1);
			m1.specular = new ColorTransform(0, 0, 0, 1);
			m1.power = 0;
			
			var m2:Material = new Material();
			m2.ambient = new ColorTransform(.1, .1, .1, 1);
			m2.diffuse = new ColorTransform(1, 1, 1, 1);
			m2.specular = new ColorTransform(0, 0, 0, 1);
			m2.power = 0;
			
			lightObj1 = new Primitives(m1, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			lightObj1.toPlane(50, 50, 1, 1);
			lightObj1.y = 1000;
			lightObj1.x = 0;
			lightObj1.z = 0;
			viewport.scene.addChild( lightObj1 );
			
			lightObj2 = new Primitives(m2, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			lightObj2.toPlane(50, 50, 1, 1);
			lightObj2.y = 1000;
			lightObj2.x = 0;
			lightObj2.z = 0;
			viewport.scene.addChild(lightObj2);
			
			light1 = new Light3D(lightObj1);
			viewport.scene.addLight(light1);
			light1.type = LightType.SPOT_LIGHT;
			light1.mode = LightType.MID_MODE;
			light1.bOnOff = LightType.LIGHT_ON;
			light1.ambient = new ColorTransform(0, 0, 0, 1);
			light1.diffuse = new ColorTransform(0, 1, 1, 1);
			light1.specular = new ColorTransform(0, 0, 0, 1);
			light1.attenuation1 = 0.0001;
			light1.attenuation2 = 0.00000001;
			
			light2 = new Light3D(lightObj2);
			viewport.scene.addLight(light2);
			light2.type = LightType.POINT_LIGHT;
			light2.mode = LightType.LOW_MODE;
			light2.bOnOff = LightType.LIGHT_ON;
			light2.ambient = new ColorTransform(0, 0, 0, 1);
			light2.diffuse = new ColorTransform(1, 1, 0, 1);
			light2.specular = new ColorTransform(0, 0, 0, 1);
			light2.attenuation1 = 0.0001;
			light2.attenuation2 = 0.00000001;
			
			moveLight1(10);
			moveLight2(10);
			
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
			text.text = "模型数量: 1  \n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n空格切换地形渲染模式\nCtrl开关雾\nShift开关透明度";
			text.textColor = 0xffff0000;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(text);
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
			
			/*var start:int;
			var position:uint = Library.alchemy3DLib.test2();
			var bitmapData:BitmapData = new BitmapData(512, 512);
			var bytes:ByteArray;
			
			start = getTimer();
			bytes = bitmapData.getPixels(bitmapData.rect);
			trace(getTimer() - start);
			bytes.position = 0;
			Library.memory.position = position;
			Library.memory.writeBytes(bytes);
			Library.alchemy3DLib.test();
			trace(getTimer() - start);
			
			start = getTimer();
			for(var i:uint = 0; i < 10000; i++)
			Library.alchemy3DLib.test2();
			trace(getTimer() - start);*/
			
			/*var start:int;
			var i:uint;
			
			var d:uint = 0;
			var a:Vector.<int> = new Vector.<int>(1);
			//a[0] = new Vector.<int>(1);
			start = getTimer();
			for(i = 0; i < 10000000; i++)
			{
				d = 1;
				d = 2;
			}
			trace(getTimer() - start);
			
			start = getTimer();
			for(i = 0; i < 10000000; i++)
				d = a[0];
			trace(getTimer() - start);*/
			/*var x:Number = 0;
			var y:Number = 3.1415926;
			var z:Number = 3.1415926;
			
			var vector:Vector3D = new Vector3D();
			
			var sp:Number = Math.sin(x * 0.5); 
			var cp:Number = Math.cos(x * 0.5); 
			var sb:Number = Math.sin(z * 0.5);
			var cb:Number = Math.cos(z * 0.5);
			var sh:Number = Math.sin(y * 0.5);
			var ch:Number = Math.cos(y * 0.5);
			
			vector.w =  ch*cp*cb + sh*sp*sb;
			vector.x = -ch*sp*cb - sh*cp*sb;
			vector.y =  ch*sp*sb - sh*cb*cp;
			vector.z =  sh*sp*cb - ch*cp*sb;
			
			trace( 1 - 2 * (vector.y * vector.y + vector.z * vector.z) );
			trace( Math.cos(y) * Math.cos(z) + Math.sin(y) * Math.sin(x) * Math.sin(z) );
			
			trace( 2 * ( vector.x * vector.y + vector.z * vector.w ) );
			trace( Math.cos(z) * Math.sin(y) * Math.sin(x) - Math.sin(z) * Math.cos(y) );
			
			trace( 2 * ( vector.x * vector.y - vector.z * vector.w ) );
			trace(Math.cos(x) * Math.sin(z));
			
			trace( 2 * ( vector.z * vector.y + vector.x * vector.w ) );
			trace(-Math.sin(x));*/
			
			mouseBegin = true;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			mouseBegin = false;
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			forwardSpeed += e.delta;
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
					dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_TRIANGLE_FSINVZB_32);
					//dae.load("asset/girl_test/girl.jpg");
					dae.parse(xml, false, null, materialList, textureList);
					dae.setupSkeletalAnimation(animationList);
					//dae.rotationZ += 180;
					dae.y = - 100;
					dae.x = Math.random() * 1000 - 500;
					dae.z = Math.random() * 1000 - 500;
					dae.terrainTrace = Entity.TERRAIN_TRACE_FIXED_HEIGHT;
					
					objects.push(dae);
					
					scene.addChild(dae);
					
					text.text = "模型数量: " + objects.length + "\n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n空格切换地形渲染模式\nCtrl开关雾\nShift开关透明度";
					break;
				
				case Keyboard.SPACE:
					switch(renderMode)
					{
						//case RenderMode.RENDER_TEXTRUED_TRIANGLE_FOG_GSINVZB_32:
						case RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32:
							terrain.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = RenderMode.RENDER_TEXTRUED_TRIANGLE_GSINVZB_32);
							break;
						
						case RenderMode.RENDER_TEXTRUED_TRIANGLE_GSINVZB_32:
							terrain.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = RenderMode.RENDER_TEXTRUED_TRIANGLE_FSINVZB_32);
							break;
						
						case RenderMode.RENDER_TEXTRUED_TRIANGLE_FSINVZB_32:
							terrain.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = RenderMode.RENDER_WIREFRAME_TRIANGLE_32);
							break;
						
						case RenderMode.RENDER_WIREFRAME_TRIANGLE_32:
							terrain.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = enbleFog ? RenderMode.RENDER_TEXTRUED_TRIANGLE_FOG_GSINVZB_ALPHA_32 : RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
							break;
					}
					
					break;
				
				case Keyboard.SHIFT:
					if(enbleAlpha)
					{
						enbleAlpha = false;
						
						water.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
					}
					else
					{
						enbleAlpha = true;
						
						water.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, renderMode = RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_ALPHA_32);
					}
					
					break;
				
				case Keyboard.CONTROL:
					if(enbleFog)
					{
						enbleFog = false;
						
						scene.addFog(null);
					}
					else
					{
						enbleFog = true;
						
						scene.addFog(fog);
					}
					
					break;
				
				case Keyboard.BACKSPACE:
					
					if(dae)
					{
						scene.removeChild(dae, false);
						dae = objects.pop() as DAE;
						//var geometry:Vector.<Mesh3D> = dae.geometry;
						//for(var i:uint = 0; i < geometry.length; i ++)
						//	geometry[i].destroy(true);
						
						dae.destroy(true);
						
						if(objects.length)
							dae = objects[objects.length - 1] as DAE;
						else
							dae = null;
						
						text.text = "模型数量: " + objects.length + "\n回车增加模型\n鼠标滚轮控制相机前进后退\n按住鼠标左键控制相机上下左右\nWSAD控制相机移动\n空格切换地形渲染模式\nCtrl开关雾\nShift开关透明度";
					}
					break;
				
				case Keyboard.END:
					
					if(dae)
						dae.visible = !dae.visible;
					break;
			}
		}
		
		protected override function onRenderTick(e:Event=null):void
		{
			//viewport.video.bitmapData.applyFilter( viewport.video.bitmapData,viewport.video.bitmapData.rect,new Point, new BlurFilter(4, 4) );
			//viewport.video.filters = [new BlurFilter()];
			//var data:ByteArray = viewport.video.bitmapData.getPixels(viewport.video.bitmapData.rect);
			//data.position = 0;
			//viewport.setBackgroundImage(viewport.video.bitmapData.rect, data);
			
			super.onRenderTick(e);
			
			water.mesh.texOffsetY = water.mesh.texOffsetY > 255 ? 0 : water.mesh.texOffsetY + 1;
			
			if(key[0])
				//camera.eye.up(-10);
				upSpeed -= 3;
			
			if(key[1])
				//camera.eye.right(-10);
				rightSpeed -= 3;
			
			if(key[2])
				//camera.eye.right(10);
				rightSpeed += 3;
			
			if(key[3])
				//camera.eye.up(10);
				upSpeed += 3;
			
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
			//trace("dsd");
			//trace(camera.eye.rotationX);
			//trace(camera.eye.rotationY);
			//trace(camera.eye.rotationZ);
			//trace(Math.atan2(camera.eye.transform.rawData[1],camera.eye.transform.rawData[5]));
			//trace(camera.eye.transform.decompose()[1]);
			//camera.eye.rotationZ = 0;
			camera.eye.right(rightSpeed);
			camera.eye.up(upSpeed);
			camera.eye.forward(forwardSpeed);
			
			var speed:uint = Math.abs(forwardSpeed) + Math.abs(upSpeed) + Math.abs(rightSpeed);
			speed -= speed & 2;
			speed >>= 5;
			viewport.video.filters = [new BlurFilter(speed, speed)];
			
			rightSpeed *= friction;
			upSpeed *= friction;
			forwardSpeed *= friction;
			
			//camera.target = dae ? dae.worldPosition : null;
			//return;
			
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
			
			if(camera.y > 3000)
				camera.y = 3000;
			
			if(camera.y < 0)
				camera.y = 0;
			
			water.x = camera.x;
			water.z = camera.z;
			
			water.rotationY = camera.eye.rotationY;
			
			//trace(camera.eye.rotationY);
			//water.y = camera.y;

			camera.distance = 1000;
			camera.target = dae ? dae.worldPosition : null;
			camera.hoverType = camera.target ? Camera3D.HOVER_TYPE_RELATIVE : Camera3D.HOVER_TYPE_NONE;
			//camera.rotationY ++;
			
			//var vector:Vector3D;
			//if( ( vector = viewport.getWorldPositionFromScreen(mouseX, mouseY) ) != null )
			//	trace(vector.x, vector.y, vector.z);
		}
		
		private function moveLight1(dir:int = 1):void
		{
			var target:int = 3000 * dir + 100;
			TweenLite.to(lightObj1, 3, { z:target, onComplete:moveLight1, onCompleteParams:[dir * -1]});
		}
		
		private function moveLight2(dir:int = 1):void
		{
			var target:int = 3000 * dir;
			TweenLite.to(lightObj2, 4, { x:target, onComplete:moveLight2, onCompleteParams:[dir * -1]});
		}
		
		private var textureData:Vector.<BitmapData>;
		private var textureMap:Vector.<String>;
		
		private var textureList:Vector.<Texture>;
		private var materialList:Vector.<Material>;
		private var animationList:Vector.<SkeletalAnimation>;
		private var geometryList:Vector.<Mesh3D>;
		
		private var objects:Vector.<Entity>;
		private var dae:DAE;
		private var water:Primitives;
		
		protected var lightObj1:Primitives;
		protected var lightObj2:Primitives;
		protected var lightObj3:Entity;
		
		protected var light1:Light3D;
		protected var light2:Light3D;
		protected var light3:Light3D;
		
		private var fog:Fog;
		
		private var loader:URLLoader;
		private var text:TextField;
		private var xml:XML;
		private var terrain:MeshTerrain;
		
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
		
		private var renderMode:uint;
		private var enbleAlpha:Boolean;
		private var enbleFog:Boolean;
		
		private var friction:Number = 0.99;
	}
}