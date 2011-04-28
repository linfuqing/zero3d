package
{
	import AlchemyLib.container.Entity;
	import AlchemyLib.events.LoadEvent;
	import AlchemyLib.external.A3DS;
	import AlchemyLib.external.DAE;
	import AlchemyLib.external.MD2;
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
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="60")]
	public class zerO extends Basic
	{
		protected var center:Primitives;
		
		protected var lightObj:Primitives;
		protected var lightObj2:Primitives;
		protected var lightObj3:Entity;
		
		protected var light:Light3D;
		protected var light2:Light3D;
		protected var light3:Light3D;
		
		private var dae:DAE;
		private var md2:MD2;
		
		public function zerO()
		{
			super(640, 480, 90, 20, 4000);
			
//			var m:Material = new Material();
//			m.ambient = new ColorTransform(1, 1, 1, 1);
//			m.diffuse = new ColorTransform(.6, .6, .6, 1);
//			m.specular = new ColorTransform(0, 0, 0, 1);
//			m.power = 0;
//			m.doubleSide = true;
			
			//center = new Primitives(m, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			//center.toPlane(100, 100, 100, 100);
			//viewport.scene.addChild(center);
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			//dae = new DAE();
			//dae.load("asset/r01.DAE");
			//dae.rotationZ += 180;
			
			//camera.y = 100;
			
			//scene.addChild(dae);

			viewport.backgroundColor = 0xffffffff;
			
//			camera.y = 100;
//			camera.rotationX += 30;
//			
//			viewport.backgroundColor = 0xffffffff;
//			
//			center = new Primitives(m, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
//			center.toPlane(1, 1, 1, 1);
//			center.mesh.terrainTrace = true;
//			viewport.scene.addChild(center);
//
			var m:Material = new Material();
			m.ambient = new ColorTransform(.2, .2, .2, 1);
			m.diffuse = new ColorTransform(.6, .6, .6, 1);
			m.specular = new ColorTransform(.5, .5, .5, 1);
			m.power = 0;
			
			var m2:Material = new Material();
			m2.ambient = new ColorTransform(.5, .5, .5, 1);
			m2.diffuse = new ColorTransform(1, 1, 1, 1);
			m2.specular = new ColorTransform(.5, .5, .5, 1);
			m2.power = 0;
			
			var m3:Material = new Material();
			m3.ambient = new ColorTransform(0, .2, .4, 1);
			m3.diffuse = new ColorTransform(.1, .2, .533, .6);
			m3.specular = new ColorTransform(1, 1, 1, 1);
			m3.power = 0;
//			
			lightObj = new Primitives(m, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			lightObj.toPlane(5, 5, 1, 1);
			lightObj.y = 200;
			lightObj.x = 0;
			lightObj.z = 0;
			viewport.scene.addChild( lightObj );
			
			lightObj2 = new Primitives(m, null, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
			lightObj2.toPlane(5, 5, 1, 1);
			lightObj2.y = 200;
			lightObj2.x = 0;
			lightObj2.z = 0;
			viewport.scene.addChild(lightObj2);
			
			light = new Light3D(lightObj);
			viewport.scene.addLight(light);
			light.type = LightType.SPOT_LIGHT;
			light.mode = LightType.MID_MODE;
			light.bOnOff = LightType.LIGHT_ON;
			light.ambient = new ColorTransform(0, 0, 0, 1);
			light.diffuse = new ColorTransform(.3, .3, 0, 1);
			light.specular = new ColorTransform(.5, .5, .5, 1);
			light.attenuation1 = 0.0001;
			light.attenuation2 = 0.00000001;
			
			light2 = new Light3D(lightObj2);
			viewport.scene.addLight(light2);
			light2.type = LightType.POINT_LIGHT;
			light2.mode = LightType.MID_MODE;
			light2.bOnOff = LightType.LIGHT_ON;
			light2.ambient = new ColorTransform(.5, .5, .5, 1);
			light2.diffuse = new ColorTransform(0, .6, .6, 1);
			light2.specular = new ColorTransform(.5, .5, .5, 1);
			light2.attenuation1 = 0.0001;
			light2.attenuation2 = 0.00000001;
//			
//			var terrain:MeshTerrain = new MeshTerrain(null, m, null, RenderMode.RENDER_GOURAUD_TRIANGLE_INVZB_32);
//			terrain.buildOn(40000, 40000, 30000);
//			terrain.mesh.octreeDepth = 3;
//			terrain.mesh.lightEnable = true;
//
//			scene.addChild(terrain);
			
			//this.startRendering();
			
			var fps:FPS = new FPS(viewport.scene);
			addChild(fps);
			
			moveLight1(1);
			moveLight2(1);
//			
//			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
//			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
			
			texture = new Texture();
			
			texture.load("asset/01.jpg");
			
			texture.addEventListener(Event.COMPLETE, onComplete);
		}
		
		private var texture:Texture;
		private function onComplete(e:Event):void
		{
			var m:Material = new Material();
			m.ambient = new ColorTransform(.2, .2, .2, 1);
			m.diffuse = new ColorTransform(.6, .6, .6, 1);
			m.specular = new ColorTransform(.3, .3, .3, 1);
			m.power = 0;
			
			m.doubleSide = true;
			
			md2 = new MD2(m, texture, RenderMode.RENDER_TEXTRUED_BILERP_TRIANGLE_INVZB_32);
			md2.load("asset/02.jpg");
			md2.rotationX -= 90;
			md2.scale = 1.5;
			//md2.y     = - 30;
			md2.z     = 20;
			md2.mesh.lightEnable = true;
			scene.addChild(md2);
			
			this.startRendering();
		}
		
		override protected function onRenderTick(e:Event = null):void
		{
			super.onRenderTick(e);
			
			//dae.rotationX ++;
			
			md2.rotationY ++;
			
			camera.target = md2.worldPosition;
				
			var mx:Number = viewport.mouseX / 500;
			var my:Number = - (viewport.mouseY - 700 )/ 7000;
				
			camera.hover(mx, my, 10);
			
			//dae.rotationX ++;
			
			//camera.z -= 1;
			
			//center.rotationY ++;

//			if ( keyCode == Keyboard.UP )
//			{
//				camera.z += speed;
//				center.z += speed;
//			}
//			
//			if ( keyCode == Keyboard.DOWN )
//			{
//				camera.z -= speed;
//				center.z -= speed;
//			}
//			
//			if ( keyCode == Keyboard.LEFT )
//			{
//				camera.x -= speed;
//				center.x -= speed;
//			}
//			
//			if ( keyCode == Keyboard.RIGHT )
//			{
//				camera.x += speed;
//				center.x += speed;
//			}
//			
//			camera.y = center.y + 200;
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			center.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, RenderMode.RENDER_WIREFRAME_TRIANGLE_32);
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			center.mesh.setAttribute(Mesh3D.RENDERMODE_KEY, RenderMode.RENDER_FLAT_TRIANGLE_INVZB_32);
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			keyCode = e.keyCode;
		}
		
		private function onKeyUp( e:KeyboardEvent ):void
		{
			keyCode = 0;
		}
		
		private var speed:Number = 20;
		private var keyCode:uint = 0;
		
		protected function moveLight1(dir:int = 1):void
		{
			var target:int = 300 * dir + 100;
			TweenLite.to(lightObj, 3, { z:target, onComplete:moveLight1, onCompleteParams:[dir * -1]});
		}
		
		protected function moveLight2(dir:int = 1):void
		{
			var target:int = 300 * dir;
			TweenLite.to(lightObj2, 4, { x:target, onComplete:moveLight2, onCompleteParams:[dir * -1]});
		}
		
//		protected function moveLight3(dir:int = 1):void
//		{
//			var target:int = 200 * dir;
//			TweenLite.to(lightObj3, 4, { y:target, onComplete:moveLight3, onCompleteParams:[dir * -1]});
//		}
	}
}