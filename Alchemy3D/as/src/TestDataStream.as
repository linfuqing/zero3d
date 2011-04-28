package
{
	import AlchemyLib.animation.AnimationObject;
	import AlchemyLib.animation.SkeletalAnimation;
	import AlchemyLib.container.Entity;
	import AlchemyLib.external.DAE;
	import AlchemyLib.geom.Mesh3D;
	import AlchemyLib.render.Material;
	import AlchemyLib.render.RenderMode;
	import AlchemyLib.render.Texture;
	import AlchemyLib.tools.Basic;
	import AlchemyLib.tools.FPS;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="60")]
	public class TestDataStream extends Basic
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
		
		public function TestDataStream(viewWidth:int=640, viewHeight:int=480, fov:Number=90, near:Number=100, far:Number=5000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			viewport.backgroundColor = 0xffffffff;
			
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
			
			var xml:XML = XML(new daeFile);
			
			dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_BILERP_TRIANGLE_INVZB_32);
			dae.parse(xml, true, null);
			dae.setBitmapData(textureData, textureMap);
			//dae.rotationZ += 180;
			dae.y = - 100;
			dae.x = 0;
			dae.z = 200;

			//scene.addChild(dae);
			
			var i:uint;
			var length:uint;
			var materialList:Vector.<Material> = dae.material;
			var textureList:Vector.<Texture> = dae.texture;
			var animationList:Vector.<SkeletalAnimation> = dae.animation;
			var material:Array = new Array();
			var texture:Array = new Array();
			var mesh:Vector.<Mesh3D> = dae.geometry;
			
			length = materialList.length;
			for(i = 0; i < length; i ++)
				material[materialList[i].name] = materialList[i];
			
			length = textureList.length;
			for(i = 0; i < length; i ++)
				texture[textureList[i].name] = textureList[i];
			
			frame = new ByteArray();
			geometry = new ByteArray();
			animation = new ByteArray();
			
			Entity.serialize(dae, frame);
			frame.position = 0;
			node = new AnimationObject();
			Entity.unserialize(frame, node);
			
			length = mesh.length
			for(i = 0; i < length; i ++)
				Mesh3D.serialize(mesh[i], geometry);
			geometry.position = 0;
			for(i = 0; i < length; i ++)
				Mesh3D.unserialize(geometry, material, texture, node);
			
			length = animationList.length;
			for(i = 0; i < length; i ++)
				SkeletalAnimation.serialize(animationList[i], animation);
			animation.position = 0;
			for(i = 0; i < length; i ++)
				animationList[i] = SkeletalAnimation.unserialize(animation);
			node.setupSkeletalAnimation(animationList);
			//node.rotationZ += 180;
			node.z = 300;
			
			scene.addChild(node);
			camera.target = new Vector3D(0, - 100, 200);
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			//camera.rotationZ += 180;

			this.startRendering();
		}
		
		private var matrix:Matrix3D = new Matrix3D();
		private var position:Vector3D = new Vector3D(0,0,300);
		protected override function onRenderTick(e:Event=null):void
		{
			super.onRenderTick(e);
			//matrix.position = position;
			//matrix.appendRotation(1, Vector3D.X_AXIS);
			//matrix.appendRotation(1, Vector3D.Y_AXIS);
			//matrix.appendRotation(1, Vector3D.Z_AXIS);
			//node.rotationY = node.rotationY;
			node.rotationX = 180;
			trace(node.transform.rawData);
			//trace(node.rotationY);
		}
		
		private var node:AnimationObject;
		private var dae:DAE;
		
		private var frame:ByteArray;
		private var geometry:ByteArray;
		private var animation:ByteArray;
		
		private var textureData:Vector.<BitmapData>;
		private var textureMap:Vector.<String>;
	}
}