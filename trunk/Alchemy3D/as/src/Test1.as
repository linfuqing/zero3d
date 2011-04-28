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
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="60")]
	public class Test1 extends Basic
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
		private var dae1:DAE;
		
		public function Test1()
		{
			super(640, 480, 50, 20, 4000);

			dae = new DAE();
			dae.load("asset/role.dae", true, true);
			//dae.scale = 5;
			dae.rotationZ += 180;
			dae.z = 300;
			
			dae1 = new DAE();
			dae1.load("asset/role.dae", false, true);
			
			camera.y = 100;
			
			scene.addChild(dae);
			scene.addChild(dae1);
			
			viewport.backgroundColor = 0xffffffff;
			
			camera.z = - 300;
			this.startRendering();
			
			var fps:FPS = new FPS(viewport.scene);
			addChild(fps);
			
			texture = new Texture();
			
			texture.load("asset/md2/blade_black.jpg");
			
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
			
			md2 = new MD2(m, texture, RenderMode.RENDER_TEXTRUED_BILERP_TRIANGLE_INVZB_32, true, true);
			md2.load("asset/md2/tris.jpg", 2);
			md2.rotationX -= 90;
			md2.scale = 5.0;
			//md2.y     = - 30;
			md2.z     = 20;
			//scene.addChild(md2);
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			//this.startRendering();
		}
		
		private var matrix:Matrix3D = new Matrix3D();
		
		override protected function onRenderTick(e:Event = null):void
		{
			super.onRenderTick(e);
			
			dae.rotationY ++;
			
			//dae.z --;
			
			//if(md2)
				//md2.rotationY ++;
		}
		
		private function onClick(e:MouseEvent):void
		{
			//md2.morphAnimation.toAnimation("run");
			dae.toAnimation("e");
			
			dae1.setupSkeletalAnimation(dae.getAnimationClipByName("a"));
			dae1.rotationZ += 180;
			dae1.z = 300;
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