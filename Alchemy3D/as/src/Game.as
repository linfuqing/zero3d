package
{
	import AlchemyLib.animation.AnimationObject;
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
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="60")]
	public class Game extends Basic
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
		
		[Embed(source="asset/lava01.jpg")]
		private var terrainTexture:Class;

		private const TERRAIN_WIDTH:Number  = 40000;
		private const TERRAIN_HEIGHT:Number = 40000;
		private const TERRAIN_LENGTH:Number = 10000;
		private const TERRAIN_HALF_WIDTH:Number = TERRAIN_WIDTH / 2;
		private const TERRAIN_HALF_HEIGHT:Number = TERRAIN_HEIGHT / 2;
		
		private const NUM_ROLE:int = 20;

		public function Game(viewWidth:int=640, viewHeight:int=480, fov:Number=90, near:Number=100, far:Number=5000)
		{
			super(viewWidth, viewHeight, fov, near, far);
			
			init();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function init():void
		{
			objects = new Vector.<Entity>();
			
			viewport.backgroundColor = 0xffffffff;
			//viewport.alphaMixed = true;
			fog = new Fog(new ColorTransform(1, 1, 1, 1), 800, 3000, 1, Fog.FOG_LINEAR);
			scene.addFog(fog);
			
			camera.x = 0;
			camera.y = 0;
			camera.z = 0;
			camera.eye.terrainTrace = Entity.TERRAIN_TRACE_BOUNDARY;
			camera.eye.setLocalAABB( new Vector3D(-500, -500, -500), new Vector3D(500, 500, 500) );
			
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
			dae.x = Math.random() * getTerrainWidth()  - getTerrainWidth()  / 2;
			dae.z = Math.random() * getTerrainHeight() - getTerrainHeight() / 2;
			dae.rotationY = Math.random() * 360;
			dae.terrainTrace = Entity.TERRAIN_TRACE_FIXED_HEIGHT;
			objects.push(dae);
			
			scene.addChild(dae);
			
			textureList = dae.texture;
			materialList = dae.material;
			animationList = dae.animation;
			geometryList = dae.geometry;
			
			var i:uint;
			/*for(i = 0; i < textureList.length; i ++)
				textureList[i].perspectiveDist = 0;*/
			
			//dae = null;
			this.startRendering();
			
			shortTimer = new Timer(500);
			
			shortTimer.addEventListener(TimerEvent.TIMER, onShortTimer);
			shortTimer.start();
			
			longTimer = new Timer(20000);
			
			var m:Material = new Material(null,
				new ColorTransform(.2, .2, .2, 0),
				new ColorTransform(.6, .6, .6, 0.6),
				new ColorTransform(.6, .6, .6, 1),
				new ColorTransform(0, 0, 0, 1) );
			
			var wt:Texture = new Texture(null, ( (new waterTexture) as Bitmap ).bitmapData);
			water = new Primitives(m, wt, RenderMode.RENDER_TRIANGLE_FOG_FSINVZB_ALPHA_32);
			water.toPlane(10000, 10000, 50, 50);
			water.mesh.octreeDepth = 2;
			water.mesh.fogEnable = true;
			water.mesh.lightEnable = true;
			water.mesh.addressMode = Mesh3D.ADDRESS_MODE_WRAP;
			water.rotationX = 90;
			water.y = -200;
			viewport.scene.addChild(water);
			
			var tt:Texture = new Texture(null, ( (new terrainTexture) as Bitmap ).bitmapData);
			terrain = new MeshTerrain(null, m, tt, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			terrain.buildOn(TERRAIN_WIDTH, TERRAIN_HEIGHT, TERRAIN_LENGTH, 1);
			terrain.mesh.octreeDepth = 3;
			//terrain.mesh.useMipmap = true;
			//terrain.mesh.mipDist = 1000;
			terrain.mesh.addressMode = Mesh3D.ADDRESS_MODE_WRAP;
			terrain.mesh.fogEnable = true;
			
			viewport.scene.addChild(terrain);
			
			var m1:Material = new Material();
			m1.doubleSide = true;
			m1.ambient = new ColorTransform(.2, .2, .2, 1);
			m1.diffuse = new ColorTransform(.6, .6, .6, 1);
			m1.specular = new ColorTransform(0, 0, 0, 1);
			m1.power = 0;
			
			var m2:Material = new Material();
			m1.doubleSide = true;
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
			
			var tm:Material = new Material();
			tm.doubleSide = true;
			tm.ambient = new ColorTransform(.2, .2, .2, 1);
			tm.diffuse = new ColorTransform(.6, .6, .6, 1);
			tm.specular = new ColorTransform(0, 0, 0, 1);
			tm.power = 0;
			target = new Primitives(tm, wt, RenderMode.RENDER_TEXTRUED_TRIANGLE_FOG_INVZB_ALPHA_32);
			target.mesh.fogEnable = true;
			target.toPlane(100, 100, 1, 1);
			scene.addChild(target);
			
			key = new Vector.<Boolean>(8);
			key[0] = key[1] = key[2] = key[3] = key[4] = key[5] = key[6] = key[7] = false;
			
			mouseStartPoint = new Point();
			mouseEndPoint = new Point();
			
			forwardSpeed = upSpeed = rightSpeed = 0;
			
			cameraDistance = cameraOldDistance = 0;
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			text = new TextField();
			text.x = (viewport.width  - text.width ) / 2;
			text.y = (viewport.height - text.height) / 2;
			text.background = true;
			text.backgroundColor = 0;
			text.textColor = 0xffffff;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(text);
			
			gameUI = new GameUI(viewport.width, viewport.height);
			//gameUI.visibleStartMenu(true);
			
			gameUI.addEventListener(GameEvent.GAME_START, onGameStart);
			gameUI.addEventListener(GameEvent.GAME_PAUSE, onGamePause);
			gameUI.addEventListener(GameEvent.GAME_CONTINUE, onGameContinue);
			//gameUI.addEventListener(GameEvent.GAME_OVER , onGameOver);
			
			addChild(gameUI);
			
			gameInfo = new GameInfo(viewport.width, viewport.height);
			addChild(gameInfo);
			
			//sceneType = 1;
			
			//onLongTimer();
			aimPoint = new Sprite();
			addChild(aimPoint);
		}

		private function getTerrainHeight():Number
		{
			return TERRAIN_HEIGHT - 5000;
		}
		
		private function getTerrainWidth():Number
		{
			return TERRAIN_WIDTH - 5000;
		}
		
		private function setRoleMove(value:Boolean):void
		{
			isMoveRole = value;
			
			var length:uint = objects.length;
			var i:uint;
			if(value)
				for(i = 0; i < length; i ++)
					(objects[i] as AnimationObject).play(true);
			else
				for(i = 0; i < length; i ++)
					(objects[i] as AnimationObject).pause();
		}
		
		private function onGameStart(e:GameEvent):void
		{
			gameType = GAME_START;
			
			setRoleMove(false);
			
			isMoveWater   = false;
			isMoveCamera  = false;
			
			mouseInput    = false;
			keyboardInput = false;
			
			longTimer.stop();
			shortTimer.stop();
			
			sceneType = -1;
		}
		
		private function onGamePause(e:GameEvent):void
		{
			if(gameType == GAME_RUNNING)
				gameInfo.pause();
		}
		
		private function onGameContinue(e:GameEvent):void
		{
			if(gameType == GAME_RUNNING)
				gameInfo.start();
		}
		
		private function addRole():void
		{
			dae = new DAE(true, true, 5, RenderMode.RENDER_TEXTRUED_TRIANGLE_INVZB_32);
			dae.parse(xml, false, null, materialList, textureList);
			dae.setupSkeletalAnimation(animationList);
			dae.x = Math.random() * getTerrainWidth()  - getTerrainWidth()  / 2;
			dae.z = Math.random() * getTerrainHeight() - getTerrainHeight() / 2;
			dae.rotationY = Math.random() * 360;
			dae.terrainTrace = Entity.TERRAIN_TRACE_FIXED_HEIGHT;
			
			objects.push(dae);
			
			scene.addChild(dae);
		}
		
		private function onAddedToStage(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			if(mouseInput && !key[4])
			{
				mouseStartPoint.x = mouseX;
				mouseStartPoint.y = mouseY;
				
				mouseBegin = true;
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			mouseBegin = false;
		}
		
		private function onClick(e:MouseEvent):void
		{
			key[5] = true;
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
					key[0] = true;
					break;
				
				case 65:
					key[1] = true;
					break;
				
				case 68:
					key[2] = true;
					break;
				
				case 83:
					key[3] = true;
					break;
				
				case Keyboard.SHIFT:
					key[4] = true;
					break;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 87:
					key[0] = false;
					break;
				
				case 65:
					key[1] = false;
					break;
				
				case 68:
					key[2] = false;
					break;
				
				case 83:
					key[3] = false;
					break;
				
				case Keyboard.SHIFT:
					key[4] = false;
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
			
			if(objects.length < NUM_ROLE)
			{
				text.text = "loading..."
				
				if(alphaStep < 0)
				{
					text.alpha += (1 - text.alpha) / 10;
					
					if(text.alpha > 0.9)
						alphaStep = - alphaStep;
				}
				else
				{
					text.alpha += (alphaStep - text.alpha) / 10;
					
					if(text.alpha < 0.1)
						alphaStep = - alphaStep;
				}
			}
			else
			{
				moveScene();
				
				if(isMoveRole)
					moveRole();
				
				if(isMoveWater)
					moveWater();
				
				if(isMoveCamera)
					moveCamera();
				
				water.x = camera.x;
				water.z = camera.z;
				
				water.rotationY = camera.eye.rotationY;
				
				if( gameUI.hitTestPoint(mouseX, mouseY, true) )
					gameUI.alpha += (1 - gameUI.alpha) / 10;
				else
					gameUI.alpha += (0.1 - gameUI.alpha) / 10;
				
				target.x = objects[0].x;
				target.y = objects[0].y + 300;
				target.z = objects[0].z;
				target.rotationY += 5;
				
				super.onRenderTick(e);
			}
			
			key[5] = false;
		}
		
		private function onLongTimer(e:TimerEvent = null):void
		{
			sceneType = Math.round(Math.random() * 4);
			
			switch(sceneType)
			{
				case 0:
					camera.step = 1;
					
					dae = objects[0] as DAE;
					
					shortTimer.delay = 3000 + 2000 * Math.random();
					setRoleMove(true);
					
					isMoveWater = true;
					isMoveCamera = true;
					
					camera.isUVN = true;
					camera.hoverType = Camera3D.HOVER_TYPE_ABSOLUT;
					
					mouseInput = false;
					keyboardInput = false;
					break;
				case 1:
					camera.step = 1;
					
					dae = objects[0] as DAE;
					
					shortTimer.delay = 1000 + 1000 * Math.random();
					
					setRoleMove(false);
					
					isMoveWater = false;
					isMoveCamera = true;
					
					camera.isUVN = true;
					camera.hoverType = Camera3D.HOVER_TYPE_ABSOLUT;
					
					mouseInput = false;
					keyboardInput = false;
					break;
				case 2:
					camera.step = 1;
					
					dae = objects[0] as DAE;
					
					shortTimer.delay = 2000 + 1000 * Math.random();
					
					setRoleMove(true);
					
					isMoveWater = true;
					isMoveCamera = true;
					
					camera.isUVN = true;
					camera.hoverType = Camera3D.HOVER_TYPE_RELATIVE;
					
					mouseInput = false;
					keyboardInput = false;
					break;
				case 3:
					shortTimer.delay = 5000 + 1000 * Math.random();
					
					setRoleMove(true);
					
					isMoveWater = true;
					isMoveCamera = true;
					
					camera.hoverType = Camera3D.HOVER_TYPE_NONE;
					
					mouseInput = false;
					keyboardInput = false;
					break;
				case 4:
					shortTimer.delay = 3000 + 1000 * Math.random();
					
					setRoleMove(true);
					
					isMoveWater = true;
					isMoveCamera = true;
					
					camera.isUVN = true;
					camera.hoverType = Camera3D.HOVER_TYPE_RELATIVE;
					
					mouseInput = false;
					keyboardInput = false;
					break;
			}
			
			onShortTimer();
		}
		
		private function onShortTimer(e:TimerEvent = null):void
		{
			if(NUM_ROLE > objects.length)
			{
				addRole();
				
				if(objects.length == NUM_ROLE)
				{
					gameUI.visibleStartMenu(true);
					
					alphaStep = 0.05;
					
					text.visible = false;
					
					onLongTimer();
					longTimer.addEventListener(TimerEvent.TIMER, onLongTimer);
					longTimer.start();
				}
				
				return;
			}
			
			switch(sceneType)
			{
				case 0:
					camera.rotationY = Math.random() * 360;
					camera.distance  = Math.random() * 500 + 100;
					break;
				case 1:
					camera.rotationY = Math.random() * 360;
					camera.distance  = Math.random() * 4000 + 1000;
					break;
				case 2:
					camera.x = Math.random() * 2000 + dae.x - 1000;
					camera.y = Math.random() * 1000 + Math.max(dae.y, 0);
					camera.z = Math.random() * 2000 + dae.z - 1000;
					break;
				case 3:
					camera.rotationX = 0;
					
					camera.x = 0;
					camera.y = 0;
					camera.z = 0;
					camera.rotationY = Math.random() * 360;
					forwardSpeed = Math.random() * 500;
					break;
				case 4:
					camera.step = 20 * Math.random() + 10;
					dae = objects[int( objects.length * Math.random() )] as DAE;
					break;
			}
		}
		
		private function moveScene():void
		{
			if(objects[0].y < 0 || camera.y < 0)
				while(camera.hoverType == Camera3D.HOVER_TYPE_ABSOLUT)
					onLongTimer();
			
			switch(sceneType)
			{
				case 0:
					if(camera.distance < 350)
						camera.rotationY += 2;
					else
						camera.rotationY -= 5;
					break;
				case 1:
					if(camera.distance > 500)
					{
						camera.distance -= 500;
						camera.distance /= 1.1;
						camera.distance += 500;
					}
					break;
				case 2:
					break;
				case 3:
					camera.y = 0;
					if(camera.x <= - getTerrainWidth() / 2 || camera.x >= getTerrainWidth() / 2 || camera.z <= - getTerrainHeight() / 2 || camera.z >= getTerrainHeight() / 2)
						forwardSpeed = - forwardSpeed;
					break;
				case 4:
					camera.x += (dae.x - camera.x) / 20;
					camera.y += (dae.y - camera.y) / 20;
					camera.z += (dae.z - camera.z) / 20;
					break;
				default:
					
					switch(gameType)
					{
						case GAME_START:
							if(alpha < alphaStep)
							{
								alphaStep = - alphaStep;
								
								setRoleMove(true);
								
								isMoveWater = true;
								
								gameInfo.addEventListener(GameEvent.TIME_OVER, onTimerOver);
								gameInfo.start(60000);
								gameInfo.pause();
								
								camera.hoverType = Camera3D.HOVER_TYPE_NONE;
								camera.isUVN = false;
								camera.step = 1;
								camera.x = 0;
								camera.y = 0;
								camera.z = 0;
								camera.rotationX = 0;
								camera.rotationY = 0;
								
								forwardSpeed = 0;
							}
							
							alpha -= alphaStep;
							
							if( alpha > (1 + alphaStep) )
							{
								alphaStep = - alphaStep;
								
								isMoveCamera = true;
								
								mouseInput = true;
								keyboardInput = true;
								
								gameInfo.start();
								
								gameType = GAME_RUNNING;
							}
							
							break;
						case GAME_RUNNING:
							//dae = objects[0] as DAE;
							//camera.UVNType = Camera3D.UVN_TYPE_RELATIVE;
							
							if(key[4])
							{
								aimPoint.visible = true;
								
								drawAimPoint();
								
								if(key[5])
								{
									var length:uint = geometryList.length;
									for(var i:uint = 0; i < length; i ++)
									{
										if(geometryList[i].isHit)
										{
											aimPoint.visible = false;
											
											gameType = GAME_WIN;
												
											gameUI.visibleWinMenu(true);
												
											break;
										}
									}
								}
							}
							else
								aimPoint.visible = false;
								
							break;
						
						case GAME_WIN:
							break;
					}
			}
		}
		
		private function drawAimPoint():void
		{
			if(key[5])
				aimPointRadius = 250;
			else
				aimPointRadius += (300 - aimPointRadius) / 5;
			
			aimPoint.graphics.clear();
			
			aimPoint.graphics.beginFill(0x00ff00, 0.5);
			aimPoint.graphics.lineStyle();
			aimPoint.graphics.drawCircle(mouseX, mouseY, aimPointRadius);
			aimPoint.graphics.endFill();
			
			aimPoint.graphics.lineStyle(1, 0);
			aimPoint.graphics.moveTo(0, mouseY);
			aimPoint.graphics.lineTo(viewport.width, mouseY);
			aimPoint.graphics.moveTo(mouseX, 0);
			aimPoint.graphics.lineTo(mouseX, viewport.height);
			
			aimPoint.graphics.beginFill(0);
			aimPoint.graphics.lineStyle();
			aimPoint.graphics.drawRect(0, 0, viewport.width, viewport.height);
			aimPoint.graphics.drawCircle(mouseX, mouseY, aimPointRadius);
			aimPoint.graphics.endFill();
			/*if(key[5])
			{
				aimPoint.graphics.lineStyle(5, 0xff0000);
				aimPoint.graphics.drawCircle(mouseX, mouseY, aimPointRadius = 200 + 200 * Math.random());
				aimPoint.graphics.lineStyle();
			}
			else
			{
				aimPoint.graphics.lineStyle(5, 0xff0000);
				aimPoint.graphics.drawCircle(mouseX, mouseY, aimPointRadius += (300 - aimPointRadius) / 10);
				aimPoint.graphics.lineStyle();
			}*/
		}
		
		private var aimPointRadius:Number = 300;
		
		private function onTimerOver(e:GameEvent):void
		{
			gameUI.visibleGameOverMenu(true);
		}
		
		private function moveRole():void
		{
			var length:uint = objects.length;
			var role:Entity;
			var isHit:Boolean;
			for(var i:uint = 0; i < length; i ++)
			{
				role = objects[i];
				isHit = false;
				role.forward(roleMoveSpeed);
				
				if(role.x < - getTerrainWidth() / 2)
				{
					role.x = - getTerrainWidth() / 2;
					isHit = true;
				}
				
				if(role.x > getTerrainWidth() / 2)
				{
					role.x = getTerrainWidth() / 2;
					isHit = true;
				}
				
				if(role.z < - getTerrainHeight() / 2)
				{
					role.z = - getTerrainHeight() / 2;
					isHit = true;
				}
				
				if(role.z > getTerrainHeight() / 2)
				{
					role.z = getTerrainHeight() / 2;
					isHit = true;
				}
				
				if(isHit)
					role.rotationY = Math.random() * 360;
			}
		}
		
		private function moveWater():void
		{
			water.mesh.texOffsetY = water.mesh.texOffsetY > 255 ? 0 : water.mesh.texOffsetY + 1;
		}
		
		private function moveCamera():void
		{
			if(mouseInput)
				mouseCamera();
			
			if(keyboardInput)
				keyboardCamera();
			
			var speed:uint = Math.abs(forwardSpeed) + Math.abs(upSpeed) + Math.abs(rightSpeed);
			speed -= speed & 2;
			speed >>= 5;
			viewport.video.filters = [new BlurFilter(speed, speed)];
			
			rightSpeed *= friction;
			upSpeed *= friction;
			forwardSpeed *= friction;
			
			camera.eye.right(rightSpeed);
			camera.eye.up(upSpeed);
			camera.eye.forward(forwardSpeed);
			
			if(camera.y > 3000)
				camera.y = 3000;
			
			if(camera.y < 0)
				camera.y = 0;
			
			/*cameraOldDistance = cameraDistance;
			if( (cameraDistance = camera.eye.position.length) > 18000 && cameraDistance > cameraOldDistance )
				friction = 0;
			else
				friction = 0.99;*/
			
			if(camera.x < - getTerrainWidth() / 2)
				camera.x = - getTerrainWidth() / 2;
						
			if(camera.x > getTerrainWidth() / 2)
				camera.x = getTerrainWidth() / 2;
						
			if(camera.z < - getTerrainHeight() / 2)
				camera.z = - getTerrainHeight() / 2;
						
			if(camera.z > getTerrainHeight() / 2)
				camera.z = getTerrainHeight() / 2;
			
			camera.target = dae ? dae.worldPosition : null;
			
			/*if(lockTarget)
			{
				camera.target = dae ? dae.worldPosition : null;
				camera.UVNType = camera.target ? (mouseInput ? Camera3D.UVN_TYPE_RELATIVE : Camera3D.UVN_TYPE_ABSOLUT) : Camera3D.UVN_TYPE_NONE;
			}
			else
				camera.UVNType = Camera3D.UVN_TYPE_NONE;*/
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
		
		private function mouseCamera():void
		{
			if(key[4])
			{
				
			}
			else
			{
				camera.rotationZ = 0;
				
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
		}
		
		private function keyboardCamera():void
		{
			if(key[0])
				upSpeed -= 3;
			
			if(key[1])
				rightSpeed -= 3;
			
			if(key[2])
				rightSpeed += 3;
			
			if(key[3])
				upSpeed += 3;
			
			if(key[4])
			{
				camera.eye.scaleX = .3;
				camera.eye.scaleY = .3;
			}
			else
			{
				camera.eye.scaleX = 1;
				camera.eye.scaleY = 1;
			}
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
		private var target:Primitives;
		
		private var lightObj1:Primitives;
		private var lightObj2:Primitives;
		private var lightObj3:Entity;
		
		private var light1:Light3D;
		private var light2:Light3D;
		private var light3:Light3D;
		
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
		
		private var friction:Number = 0.99;
		
		private var roleMoveSpeed:Number = -30;
		
		private var alphaStep:Number = 0.05;
		
		//private var lockTarget:Boolean;
		private var mouseInput:Boolean;
		private var keyboardInput:Boolean;
		
		private var isMoveRole:Boolean;
		private var isMoveCamera:Boolean;
		private var isMoveWater:Boolean;
		
		private var sceneType:int;
		private var gameType:int;
		
		private var cameraPosition:Vector3D;
		private var cameraDistance:Number;
		private var cameraOldDistance:Number;
		
		private var gameUI:GameUI;
		
		private var gameInfo:GameInfo;
		
		private var aimPoint:Sprite;
		
		private var longTimer:Timer;
		
		private var shortTimer:Timer;
		
		private static const GAME_START:int   = 0;
		private static const GAME_RUNNING:int = 1;
		private static const GAME_WIN:int     = 2;
	}
}
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.filters.GradientGlowFilter;
import flash.text.TextFieldAutoSize;

class GameEvent extends Event
{
	public static const GAME_START:String = "game start";
	public static const GAME_PAUSE:String = "game pause";
	public static const GAME_CONTINUE:String = "game continue";
	public static const GAME_OVER :String = "game over";
	
	public static const CLOSE_MENU:String = "close menu";
	
	public static const TIME_OVER:String = "time over";

	public function GameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
}

class GameInfo extends Sprite
{
	public function GameInfo(viewWidth:Number, viewHeight:Number):void
	{
		time = new TextField();
		time.x = viewWidth / 2 - 10;
		time.y = 50;
		time.thickness = 200;
		time.borderColor = 0;
		time.border = true;
		time.autoSize = TextFieldAutoSize.LEFT;
		time.filters = [new DropShadowFilter()/*, new GradientGlowFilter()*/];
		time.visible = false;
		addChild(time);
		
		message = new TextField();
		addChild(message);
		
		timer = new Timer(1000.0 / 60);
		_totalTime = 0;
	}
	
	public function setMessage(info:String):void
	{
		message.text = info;
	}
	
	public function start(totalTime:uint = 0):void
	{
		timer.start();
		
		if(totalTime)
		{
			time.visible = true;
			
			_totalTime = totalTime & 0x7FFFFFFF;
			
			_currentTime = _totalTime;
			
			updataTime();
			
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
	}
	
	public function pause():void
	{
		timer.stop();
	}
	
	public function stop():void
	{
		timer.stop();
		
		timer.removeEventListener(TimerEvent.TIMER, onTimer);
	}
	
	private function updataTime():void
	{
		var minutes:uint = _currentTime / 1000;
		var seconds:uint = (_currentTime % 1000) / 1000.0 * 60 + 0.5;
		time.text = (minutes < 10 ? '0' : "") + minutes + ":" + (seconds < 10 ? '0' : "") + seconds;
		
		time.textColor = minutes < 5 ? 0xff0000 : 0;
	}
	private function onTimer(e:TimerEvent = null):void
	{
		updataTime();
		
		if(_currentTime < 0)
		{
			this.dispatchEvent( new GameEvent(GameEvent.TIME_OVER) );
			
			stop();
		}
		else
			_currentTime = _currentTime - 1000.0 / 60;
	}
	
	private var time:TextField;
	private var message:TextField;
	
	private var timer:Timer;
	
	private var _currentTime:int;
	private var _totalTime:uint;
}

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

class GameUI extends Sprite
{
	[Embed(source="asset/v4/mianban2.png")]
	private var startBitmap:Class;
	
	[Embed(source="asset/flame.png")]
	private var startGameBitmap:Class;
	
	[Embed(source="asset/bt_startGame/startGameUsual.png")]
	private var startGameUpBitmap:Class;
	
	[Embed(source="asset/bt_startGame/startGameFocus.png")]
	private var startGameOverBitmap:Class;
	
	[Embed(source="asset/bt_startGame/startGameOn.png")]
	private var startGameDownBitmap:Class;
	
	[Embed(source="asset/bt_configuration/configurationUsual.png")]
	private var configurationUpBitmap:Class;
	
	[Embed(source="asset/bt_configuration/configurationFocus.png")]
	private var configurationOverBitmap:Class;
	
	[Embed(source="asset/bt_configuration/configurationOn.png")]
	private var configurationDownBitmap:Class;
	
	[Embed(source="asset/bt_information/informationUsual.png")]
	private var informationUpBitmap:Class;
	
	[Embed(source="asset/bt_information/informationFocus.png")]
	private var informationOverBitmap:Class;
	
	[Embed(source="asset/bt_information/informationOn.png")]
	private var informationDownBitmap:Class;
	
	[Embed(source="asset/bt_replay/replayUsual.png")]
	private var replayUpBitmap:Class;
	
	[Embed(source="asset/bt_replay/replayFocus.png")]
	private var replayOverBitmap:Class;
	
	[Embed(source="asset/bt_replay/replayOn.png")]
	private var replayDownBitmap:Class;
	
	[Embed(source="asset/bt_continue/continueUsual.png")]
	private var continueUpBitmap:Class;
	
	[Embed(source="asset/bt_continue/continueFocus.png")]
	private var continueOverBitmap:Class;
	
	[Embed(source="asset/bt_continue/continueOn.png")]
	private var continueDownBitmap:Class;
	
	[Embed(source="asset/v4/yuan2.png")]
	private var closeBitmap:Class;
	
	[Embed(source="asset/v4/min2.png")]
	private var pauseBitmap:Class;
	
	/*[Embed(source="asset/skin01.jpg")]
	private var informationBitmap:Class;
	
	[Embed(source="asset/barrier.png")]
	private var gameOverBitmap:Class;
	
	[Embed(source="asset/skin01.jpg")]
	private var winBitmap:Class;*/
	
	public function GameUI(viewWidth:Number, viewHeight:Number)
	{
		_viewWidth  = viewWidth;
		_viewHeight = viewHeight;
		
		init();
		
		startGameButton.addEventListener(MouseEvent.CLICK, onStartGame);
		configurationButton.addEventListener(MouseEvent.CLICK, onConfiguration);
		informationButton.addEventListener(MouseEvent.CLICK, onInformationButton);
		closeButton.addEventListener(MouseEvent.CLICK, onClose);
		pauseButton.addEventListener(MouseEvent.CLICK, onPauseButton);
		continueButton.addEventListener(MouseEvent.CLICK, onContinueButton);
		replayButton.addEventListener(MouseEvent.CLICK, onStartGame);
		
		//timer = new Timer(1000);
		//timer.addEventListener(TimerEvent.TIMER, onTimer);
	}
	
	private function init():void
	{
		oldCloseType = new Vector.<String>();
		
		start = (new startBitmap) as Bitmap;
		start.x = (_viewWidth - start.width) / 2;
		start.y = (_viewHeight - start.height) / 2;
		
		pause = (new startBitmap) as Bitmap;//(new pauseBitmap) as Bitmap;
		pause.x = (_viewWidth - pause.width) / 2;
		pause.y = (_viewHeight - pause.height) / 2;
		
		gameOver = (new startBitmap) as Bitmap;//(new gameOverBitmap) as Bitmap;
		gameOver.x = (_viewWidth - gameOver.width) / 2;
		gameOver.y = (_viewHeight - gameOver.height) / 2;
		
		win = (new startBitmap) as Bitmap;//(new winBitmap) as Bitmap;
		win.x = (_viewWidth - win.width) / 2;
		win.y = (_viewHeight - win.height) / 2;
		
		configuration = (new startBitmap) as Bitmap;//(new configurationBitmap) as Bitmap;
		configuration.x = (_viewWidth - configuration.width) / 2;
		configuration.y = (_viewHeight - configuration.height) / 2;
		
		information = (new startBitmap) as Bitmap;//(new informationBitmap) as Bitmap;
		information.x = (_viewWidth - information.width) / 2;
		information.y = (_viewHeight - information.height) / 2;
		
		infoText = new TextField();
		infoText.autoSize = TextFieldAutoSize.LEFT;
		infoText.wordWrap = true;
		infoText.text = "";
		infoText.x = information.x + 50;
		infoText.y = information.y + 50;
		//time = new TextField();
		//time.x = _viewWidth - 100;
		//time.y = _viewHeight - 100;
		
		startGameButton     = new SimpleButton(new startGameUpBitmap, new startGameOverBitmap, new startGameDownBitmap);
		configurationButton = new SimpleButton(new configurationUpBitmap, new configurationOverBitmap, new configurationDownBitmap);
		informationButton   = new SimpleButton(new informationUpBitmap, new informationOverBitmap, new informationDownBitmap);
		closeButton         = new SimpleButton(new closeBitmap, new closeBitmap, new closeBitmap);
		pauseButton         = new SimpleButton(new pauseBitmap, new pauseBitmap, new pauseBitmap);
		continueButton      = new SimpleButton(new continueUpBitmap, new continueOverBitmap, new continueDownBitmap);
		replayButton        = new SimpleButton(new replayUpBitmap, new replayOverBitmap, new replayDownBitmap);
		
		startGameButton.hitTestState = startGameButton.overState;
		configurationButton.hitTestState = configurationButton.overState;
		informationButton.hitTestState = informationButton.overState;
		closeButton.hitTestState = closeButton.overState;
		pauseButton.hitTestState = pauseButton.overState;
		continueButton.hitTestState = continueButton.overState;
		replayButton.hitTestState = replayButton.overState;
		
		startGameButton.x = start.x + 20;
		startGameButton.y = start.y + 100;
		
		configurationButton.x = start.x + 20;
		configurationButton.y = start.y + 150;
		
		informationButton.x = start.x + 20;
		informationButton.y = start.y + 200;
		
		continueButton.x = startGameButton.x;
		continueButton.y = startGameButton.y;
		
		replayButton.x = startGameButton.x;
		replayButton.y = startGameButton.y;
		
		pauseButton.x = _viewWidth - pauseButton.width;
		pauseButton.y = 0;//_viewHeight - pauseButton.height;
		
		//addChild(time);
		addChild(start);
		addChild(pause);
		addChild(gameOver);
		addChild(win);
		addChild(configuration);
		addChild(information);
		
		addChild(infoText);
		
		addChild(startGameButton);
		addChild(continueButton);
		addChild(replayButton);
		addChild(configurationButton);
		addChild(informationButton);
		addChild(closeButton);
		addChild(pauseButton);
		
		setVisible(false);
	}
	
	public override function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean=false):Boolean
	{
		var length:uint = numChildren;
		var child:DisplayObject;
		for(var i:uint = 0; i < length; i ++)
		{
			if( ( child = getChildAt(i) ).visible && child.hitTestPoint(x, y, shapeFlag) )
				return true;
		}
		
		return false;
	}
	
	public function visibleStartMenu(value:Boolean):void
	{
		setVisible(false);
		
//		startGameButton.x = start.x + 50;
//		configurationButton.x = start.x + 50;
//		informationButton.x = start.x + 50;
//		
//		startGameButton.y = start.y - 50;
//		configurationButton.y = start.y + 50;
//		informationButton.y = start.y + 150;
		
		start.visible = value;
		startGameButton.visible = value;
		configurationButton.visible = value;
		informationButton.visible = value;
		
		if( value && newCloseType != START_MENU && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != START_MENU )
		{
			oldCloseType.push(newCloseType);
			newCloseType = START_MENU;
		}
		
		setCloseButtonPosition();
		
		currentMenu = START_MENU;
	}
	
	public function visiblePauseMenu(value:Boolean):void
	{
		setVisible(false);
		
//		continueButton.x = start.x + 50;
//		configurationButton.x = start.x + 50;
//		informationButton.x = start.x + 50;
//		
//		continueButton.y = start.y - 50;
//		configurationButton.y = start.y + 50;
//		informationButton.y = start.y + 150;
		
		pause.visible = value;
		continueButton.visible = value;
		informationButton.visible = value;
		
		if( value && newCloseType != PAUSE_MENU && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != PAUSE_MENU )
		{
			oldCloseType.push(newCloseType);
			newCloseType = PAUSE_MENU;
		}
		
		setCloseButtonPosition();
		
		currentMenu = PAUSE_MENU;
	}
	
	public function visibleGameOverMenu(value:Boolean):void
	{
		setVisible(false);
		
//		replayButton.x = start.x + 50;
//		configurationButton.x = start.x + 50;
//		informationButton.x = start.x + 50;
//		
//		replayButton.y = start.y - 50;
//		configurationButton.y = start.y + 50;
//		informationButton.y = start.y + 150;
		
		gameOver.visible = value;
		replayButton.visible = value;
		configurationButton.visible = value;
		informationButton.visible = value;
		
		if( value && newCloseType != GAME_OVER_MENU && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != GAME_OVER_MENU )
		{
			oldCloseType.push(newCloseType);
			newCloseType = GAME_OVER_MENU;
		}
		
		setCloseButtonPosition();
		
		currentMenu = GAME_OVER_MENU;
	}
	
	public function visibleWinMenu(value:Boolean):void
	{
		setVisible(false);
		
		win.visible = value;
		replayButton.visible = value;
		configurationButton.visible = value;
		informationButton.visible = value;
		
		if( value && newCloseType != WIN_MENU && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != WIN_MENU )
		{
			oldCloseType.push(newCloseType);
			newCloseType = WIN_MENU;
		}
		
		setCloseButtonPosition();
		
		currentMenu = WIN_MENU;
	}
	
	public function visibleConfigurationMenu(value:Boolean):void
	{
		setVisible(false);
		
		configuration.visible = value;

		if( value && newCloseType != CONFIGURATION && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != CONFIGURATION )
		{
			oldCloseType.push(newCloseType);
			newCloseType = CONFIGURATION;
		}
		
		setCloseButtonPosition();
	}
	
	public function visibleInformationMenu(value:Boolean):void
	{
		setVisible(false);
		
		information.visible = value;
		infoText.visible = value;
		
		if( value && newCloseType != INFORMATION && (oldCloseType.length == 0 || oldCloseType[oldCloseType.length - 1]) != INFORMATION )
		{
			oldCloseType.push(newCloseType);
			newCloseType = INFORMATION;
		}
		
		setCloseButtonPosition();
	}

	/*private function onTimer(e:TimerEvent):void
	{
		if(totalTime < 0)
		{
			timer.stop();
			
			this.dispatchEvent( new GameEvent(GameEvent.GAME_OVER) );
			
			visibleGameOverMenu(true);
		}
		else
		{
			time.text = totalTime.toString();
			
			totalTime --;
		}
	}*/
	
	private function onStartGame(e:MouseEvent):void
	{
		closeAll();
		
		//totalTime = 5;
		//time.visible = true;
		//timer.start();
		
		pauseButton.visible = true;
		
		currentMenu = PAUSE_MENU;
		
		this.dispatchEvent( new GameEvent(GameEvent.GAME_START) );
	}
	
	private function onConfiguration(e:MouseEvent):void
	{
		visibleConfigurationMenu(true);
	}
	
	private function onInformationButton(e:MouseEvent):void
	{
		visibleInformationMenu(true);
	}
	
	private function onPauseButton(e:MouseEvent = null):void
	{
		setVisible(false);
		
		setMenuVisible(currentMenu, true)
		
		if(currentMenu && !menuOn)
		{
			//timer.stop();
		
			this.dispatchEvent( new GameEvent(GameEvent.GAME_PAUSE) );
		}
	}
	
	private function onContinueButton(e:MouseEvent = null):void
	{
		closeAll();
		
		//time.visible = true;
		//timer.start();
		
		pauseButton.visible = true;
		
		currentMenu = PAUSE_MENU;
		
		this.dispatchEvent( new GameEvent(GameEvent.GAME_CONTINUE) );
	}
	
	private function setMenuVisible(type:String, value:Boolean):void
	{
		switch(type)
		{
			case START_MENU:
				visibleStartMenu(value);
				break;
			
			case PAUSE_MENU:
				visiblePauseMenu(value);
				break;
			
			case GAME_OVER_MENU:
				visibleGameOverMenu(value);
				break;
			
			case WIN_MENU:
				visibleWinMenu(value);
				break;
			
			case CONFIGURATION:
				visibleConfigurationMenu(value);
				break;
			
			case INFORMATION:
				visibleInformationMenu(value);
				break;
		}
	}
	
	private function closeAll():void
	{
		menuOn = false;
		
		oldCloseType.splice(0, oldCloseType.length);
		
		newCloseType = null;
		
		setVisible(false);
	}
	
	private function onClose(e:MouseEvent = null):void
	{
		menuOn = true;
		
		setMenuVisible(newCloseType, false);
		
		newCloseType = oldCloseType.pop();
		
		setCloseButtonPosition();
		
		setMenuVisible(newCloseType, true);
		
		if(!newCloseType)
		{
			pauseButton.visible = true;
			
			this.dispatchEvent( new GameEvent(GameEvent.CLOSE_MENU) );
		}
	}
	
	private function setCloseButtonPosition():void
	{
		var src:DisplayObject;
		switch(newCloseType)
		{
			case START_MENU:
				src = start;
				break;
			
			case PAUSE_MENU:
				src = pause;
				break;
			
			case GAME_OVER_MENU:
				src = gameOver;
				break;
			
			case WIN_MENU:
				src = win;
				break;
			
			case CONFIGURATION:
				src = configuration;
				break;
			
			case INFORMATION:
				src = information;
				break;
			
			default:
				src = null;
		}
		
		if(src)
		{
			closeButton.x = src.x + src.width - closeButton.width;
			closeButton.y = src.y;
			
			closeButton.visible = true;
		}
		else
			closeButton.visible = false;
	}
	
	private function setVisible(value:Boolean):void
	{
		start.visible = value;
		pause.visible = value;
		gameOver.visible = value;
		win.visible = value;
		configuration.visible = value;
		information.visible = value;
		startGameButton.visible = value;
		continueButton.visible = value;
		replayButton.visible = value;
		configurationButton.visible = value;
		informationButton.visible = value;
		closeButton.visible = value;
		pauseButton.visible = value;
		infoText.visible = value;
		//time.visible = value;
	}
	
	private var _viewWidth:Number;
	private var _viewHeight:Number;
	
	private var configuration:Bitmap;
	private var information:Bitmap;
	private var start:Bitmap;
	private var pause:Bitmap;
	private var gameOver:Bitmap;
	private var win:Bitmap;
	
	//private var time:TextField;
	//private var timer:Timer;
	//private var totalTime:int;
	private var infoText:TextField;
	
	private var startGameButton:SimpleButton;
	private var configurationButton:SimpleButton;
	private var informationButton:SimpleButton;
	private var closeButton:SimpleButton;
	private var pauseButton:SimpleButton;
	private var continueButton:SimpleButton;
	private var replayButton:SimpleButton;
	
	private var newCloseType:String;
	private var oldCloseType:Vector.<String>;
	
	private var currentMenu:String;
	
	private var menuOn:Boolean
	
	private const START_MENU:String = "start menu";
	private const GAME_OVER_MENU:String = "game over menu";
	private const PAUSE_MENU:String = "pause menu";
	private const WIN_MENU:String = "win menu";
	private const INFORMATION:String = "information";
	private const CONFIGURATION:String = "configuration";
}