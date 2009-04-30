/**
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
**/
package zerO.objects
{
	import __AS3__.vec.Vector;
	
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.ascollada.ASCollada;
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.ascollada.io.DaeReader;
	import org.ascollada.namespaces.*;
	import org.ascollada.types.*;
	
	import zerO.events.FileLoadEvent;
	import zerO.geom.Geometry;
	import zerO.geom.line.Line;
	import zerO.geom.line.Lines;
	import zerO.geom.points.Vertex;
	import zerO.geom.triangle.Triangle;
	import zerO.materials.BitmapFileMaterial;
	import zerO.materials.ColorMaterial;
	import zerO.materials.IMaterial;
	import zerO.materials.ITriangleMaterial;
	import zerO.materials.Materials;
	import zerO.materials.TriangleMaterial;
	import zerO.materials.WireframeMaterial;
	import zerO.materials.line.LineBrushwork;
	import zerO.materials.line.LineMaterial;
	import zerO.physics.animation.KeyFrame;
	import zerO.physics.animation.channel.AnimationChannel;
	import zerO.physics.animation.channel.MatrixChannel;
	import zerO.physics.controllers.AnimationController;
	import zerO.physics.controllers.SkinController;
	
	/**
	 * DAE导入，你可以使用它导入外部DAE格式的3D数据.
	 * 像这样：
	 * <p>
	 * var dae:DAE = new DAE();
	 * <p>
	 * dae.load(DAE地址);
	 * <p>
	 * 如果你的DAE中包含动画.那么你可以这样获取动画播放器.
	 * <p>
	 * var controller:IController = dae.getControllerByName( "animation" );
	 * <p>
	 */
	public class DAE extends DisplayObject3D
	{
		//默认图片格式
		/** Alternative file-extension for TGA images. Default is "png". */
		public static var DEFAULT_TGA_ALTERNATIVE:String = "png";
		
		//使用材质的目标名字（材质导入时候用）
		/** Defines wether to set materials by target id or name - Might fix C4D**/
		public var useMaterialTargetName:Boolean = false;
		
		/** change this to 0 if you're DAE is picking the wrong coordinates */
		// 当发生错误时请把这个值设置为0
		public var forceCoordSet : int = 0;
		
		// collada...不知道是什么的话百度一下
		/** The loaded XML. */
		public var COLLADA:XML;
		
		//文件名：
		/** The filename - if applicable. */
		public var filename:String;
		
		//文件标题：
		/** The filetitle - if applicable. */
		public var fileTitle:String;
		
		//基础地址，DAE搜索位图时用
		/** Base url. */
		public var baseUrl:String;
		
		//图片地址：
		/** Path where the textures should be loaded from. */
		public var texturePath:String;
		
		//DAE导入器:
		/** The COLLADA parser. */
		public var parser:DaeReader;
		
		//DAE库:
		/** The DaeDocument. @see org.ascollada.core.DaeDocument */
		public var document:DaeDocument;
		
		//DAEID:	
		/** */
		private var _colladaID:Dictionary;
		
		//DAE备用ID
		/** */
		private var _colladaSID:Dictionary;
		
		//存储DAEID项目：
		/** */
		private var _colladaIDToObject:Object;
		
		//存储DAESID项目：
		/** */
		private var _colladaSIDToObject:Object;
		
		//结点项目：
		/** */
		private var _objectToNode:Object;
		
		//存储动画控制器（下标为目标）：
		/** */
		private var _channelsByTarget:Dictionary;
		
		//几何体列表：
		/** */
		private var _geometries:Object;
		
		//渲染材质列表：
		/** */
		private var _queuedMaterials:Array;
		
		//图片设置列表：
		/** */
		private var _textureSets:Object;
		
		//骨骼列表：
		/** */
		private var _skins:Dictionary;
		
		//骨骼数：
		/** */
		private var _numSkins:uint;
		
		//根结点:
		/** */
		public var _rootNode:DisplayObject3D;
		
		//是否动画：
		/** */
		private var _isAnimated:Boolean = false;
		
		//骨骼控制器列表：
		/** */
		private var animations:AnimationController; 
		
		//数组动画列表：
		private var _bindVertexInputs : Dictionary;
		
		/**
		 * 构造新的DAE.
		 * constructor.
		 * 
		 * @param	asset		filename or ByteArray of the dae.
		 * @param	materials	optional MaterialsList, will override any material defined in the dae.
		 * @param	async		load some stuff async to prevent timeout errors.
		 * @return
		 */
		public function DAE( name:String=null,autoPlay:Boolean = true,loop:Boolean = true ):void
		{
			super(name);
			
			this.autoPlay = autoPlay;
			this.loop = loop;
		}
		
				
		/**
		 * DAE读取
		 * 
		 * Loads the COLLADA.
		 * 
		 * @param	asset The url, an XML object or a ByteArray specifying the COLLADA file.
		 * @param	materials	An optional materialsList.
		 */ 
		public function load(asset:*, materials:Materials = null, asynchronousParsing : Boolean = false):void
		{
			this.materials = materials ? materials : new Materials();
			
			buildFileInfo(asset);
			
			_bindVertexInputs = new Dictionary(true);

			this.parser = new DaeReader(asynchronousParsing);
			this.parser.addEventListener(Event.COMPLETE, onParseComplete);
			this.parser.addEventListener(ProgressEvent.PROGRESS,onParseProgress );
			
			if(asset is XML)
			{
				this.COLLADA = asset as XML;
				this.parser.loadDocument(asset);
			}
			else if(asset is ByteArray)
			{
				this.COLLADA = new XML(ByteArray(asset));
				this.parser.loadDocument(asset);
			}
			else if(asset is String)
			{
				this.filename = String(asset);
				this.parser.read(this.filename);
			}
			else
			{
				throw new Error("load : unknown asset type!");
			}
		}
		
		/**
		 * 建造文件地址
		 * 
		 * @param	asset
		 * @return
		 */
		private function buildFileInfo( asset:* ):void
		{
			this.filename = asset is String ? String(asset) : "./texture/car.dae";
			
			// make sure we've got forward slashes!
			this.filename = this.filename.split("\\").join("/");
				
			if( this.filename.indexOf("/") != -1 )
			{
				// dae is located in a sub-directory of the swf.
				var parts:Array = this.filename.split("/");
				this.fileTitle = String( parts.pop() );
				this.baseUrl = parts.join("/");
			}
			else
			{
				// dae is located in root directory of swf.
				this.fileTitle = this.filename;
				this.baseUrl = "";
			}
		}
		
		private function onParseProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * DAE读取完成调用
		 * 
		 * Called when the DaeReader completed parsing.
		 * 
		 * @param	event
		 */
		private function onParseComplete(event:Event):void
		{
			var reader:DaeReader = event.target as DaeReader;
			
			this.document = reader.document;
			
			_textureSets = new Object();
			_colladaID = new Dictionary(true);
			_colladaSID = new Dictionary(true);
			_colladaIDToObject = new Object();
			_colladaSIDToObject = new Object();
			_objectToNode = new Object();
			_skins = new Dictionary(true);
			
			buildMaterials();
			loadNextMaterial();
		}
		
		/**
		 * 建立材质
		 * 
		 * Builds the materials.
		 */ 
		private function buildMaterials():void
		{
			_queuedMaterials = new Array();
			
			for( var materialId:String in this.document.materials )
			{
				var material:ITriangleMaterial = null;
				var daeMaterial:DaeMaterial = this.document.materials[ materialId ];
				
				var symbol:String = this.document.materialTargetToSymbol[ daeMaterial.id ];
				
				var mat:IMaterial;
				if(useMaterialTargetName){
					mat = this.materials.getMaterialBySymbol(materialId);
					
				}else{
					mat = this.materials.getMaterialBySymbol(symbol);
				}
				
				/*
				 This next if block is a hack based on materials having their names as the bitmaps URL. 
				 If the material WAS passed in but given the same name as the bitmap's URL, then we 
				 add another material to the materials list using the symbol name.				 
				 */
				if( mat == null) 
				{
				    var matID:String = getSymbolName( daeMaterial.effect );
				    mat = this.materials.getMaterialBySymbol(matID);
				    // remove bad reference BEFORE adding the next - otherwise, they'll both be removed
				    this.materials.removeMaterial(mat);
				    if( mat ) 
				    {
				        if(useMaterialTargetName)
				        {
				             this.materials.addMaterial(mat, materialId);
				        }
				        else
				        {
				             this.materials.addMaterial(mat, symbol);
				        }
				    }

				}
					
				var effect:DaeEffect = document.effects[ daeMaterial.effect ];
				
				var lambert:DaeLambert = effect.color as DaeLambert;
				
				// save the texture-set if necessary
				if(lambert && lambert.diffuse.texture)
				{
					_textureSets[symbol] = lambert.diffuse.texture.texcoord;
				}
				
				// material already exists in our materialsList, no need to process
				if(mat){
					continue;
				}
					
				// if the material has a texture, qeueu the bitmap
				if(effect && effect.texture_url)
				{				
					var image:DaeImage = document.images[effect.texture_url];
					if(image)
					{
						var imageUrl:String = buildImagePath(this.baseUrl, image.init_from);
					
						material = new BitmapFileMaterial();
						material.doubleSided = effect.double_sided;
						_queuedMaterials.push({symbol:symbol, url:imageUrl, material:material, target:materialId});
						continue;
					}
				}

				if(lambert && lambert.diffuse.color)
				{
					if(effect.wireframe)
						material = new WireframeMaterial(new LineBrushwork( 1,buildColor( lambert.diffuse.color ) ) );
					else
						material = new ColorMaterial(buildColor(lambert.diffuse.color));
				}
				else
					material = TriangleMaterial.DEFAULT_MATERIAL;
					
				material.doubleSided = effect.double_sided;
				
				if(useMaterialTargetName){
					this.materials.addMaterial(material, materialId);
					
				}else{
					this.materials.addMaterial(material, symbol);
				}
			}
		}
		
		/**
		 * 从名字获取名称
		 */	
		private function getSymbolName(effectID:String):String
		{
		    var ef:DaeEffect;
		    for each ( var effect:DaeEffect in this.document.effects )
		    {
		       // trace("locating effect", effect.id, effectID);
		        if( effect.id == effectID ) 
		        {
		            return effect.texture_url;
		        }
		    }

		    return null;
		}
		
		/**
		 *建立位图地址
		 * 
		 * @return
		 */
		private function buildImagePath( meshFolderPath:String, imgPath:String ):String
		{
			if (texturePath != null)
				imgPath = texturePath + imgPath.slice( imgPath.lastIndexOf("/") + 1 );
			
			var baseParts:Array = meshFolderPath.split("/");
			var imgParts:Array = imgPath.split("/");
			
			while( baseParts[0] == "." )
				baseParts.shift();
				
			while( imgParts[0] == "." )
				imgParts.shift();
				
			while( imgParts[0] == ".." )
			{
				imgParts.shift();
				baseParts.pop();
			}
						
			var imgUrl:String = baseParts.length > 1 ? baseParts.join("/") : (baseParts.length?baseParts[0]:"");
						
			imgUrl = imgUrl != "" ? imgUrl + "/" + imgParts.join("/") : imgParts.join("/");
			
			return imgUrl;
		}
		
		/**
		 * 读取外部材质
		 * 
		 * Loads the next material.
		 * 
		 * @param	event
		 */ 
		private function loadNextMaterial(event:FileLoadEvent=null):void
		{
			if(event)
			{
				var previous:BitmapFileMaterial = event.target as BitmapFileMaterial;
			}
			
			if(_queuedMaterials.length)
			{
				var data:Object = _queuedMaterials.shift();
				var url:String = data.url;
				var symbol:String = data.symbol;
				var target:String = data.target;
				
				url = url.replace(/\.tga/i, "."+DEFAULT_TGA_ALTERNATIVE);
				
				var material:BitmapFileMaterial = data.material;
				material.addEventListener(Event.COMPLETE, loadNextMaterial);
				
				// shouldn't need the ?nc no cache filename now that BitmapFileMaterial has been fixed. 
                material.load( url );

				if(useMaterialTargetName){
					material.name = target;
					this.materials.addMaterial(material, target);
				}else{
					material.name = symbol;
					this.materials.addMaterial(material, symbol);
				}
			}
			else
			{
				onMaterialsLoaded();
				//buildScene();
			}
		}
		
		private function onMaterialsLoaded() : void
		{
			
			if(this.parser.hasEventListener(Event.COMPLETE))
				this.parser.removeEventListener(Event.COMPLETE, onParseComplete);

			//may have geometries to be parsed
			if(document.numQueuedGeometries)
			{
				this.parser.addEventListener(Event.COMPLETE, onParseGeometriesComplete);
				//this.parser.addEventListener(ProgressEvent.PROGRESS, onParseGeometriesProgress);
				this.parser.readGeometries();
			}
			else
			{
				buildScene(); 
			}
		}
		
		private function onParseGeometriesComplete(e:Event) : void
		{
			if(this.parser.hasEventListener(Event.COMPLETE))
				this.parser.removeEventListener(Event.COMPLETE, onParseGeometriesComplete);
			buildScene(); 
		}
		
		/**
		 * 建立场景
		 * 
		 * Builds the scene.
		 */ 
		private function buildScene():void
		{
			buildGeometries();
			
			_rootNode = new DisplayObject3D(name);
			
			for(var i:int = 0; i < this.document.vscene.nodes.length; i++)
			{
				buildNode(this.document.vscene.nodes[i], _rootNode);
			}
			
			// link the skins
			linkSkins();
			
			this.addChild(_rootNode);
			
			if(this.yUp)
			{
				_rootNode.rotationZ = 180;
			}
			else
			{
				_rootNode.rotationX = 90;
			}
			
			_isAnimated = false;
			
			// may have animations to be parsed.
			if(document.numQueuedAnimations)
			{
				_isAnimated = true;
				
				this.parser.addEventListener(Event.COMPLETE, onParseAnimationsComplete);
				this.parser.addEventListener(ProgressEvent.PROGRESS, onParseAnimationsProgress);
				this.parser.readAnimations();
			}
			
			dispatchEvent(new FileLoadEvent( Event.COMPLETE, this.filename));
		}

		/**
		 * 建立几何体
		 * 
		 * Builds all COLLADA geometries.
		 */ 
		private function buildGeometries():void
		{
			var i:int, j:int, k:int;
			
			_geometries = new Object();

			for each(var geometry:DaeGeometry in this.document.geometries)
			{
				if(geometry.mesh)
				{
					var g:Geometry = new Geometry();
					
					g.vertices = buildVertices(geometry.mesh);

					if(!g.vertices.length)
						continue;
						
					for(i = 0; i < geometry.mesh.primitives.length; i++)
					{
						buildFaces(geometry.mesh.primitives[i], g, 0);
					}
					
					_geometries[geometry.id] = g;
				}
				else if(geometry.spline && geometry.splines)
				{
					var lines:Lines = new Lines();
					var lineMaterial:LineMaterial = LineMaterial.DEFALUT_MATERIAL;
					
					for(i = 0; i < geometry.splines.length; i++)
					{
						var spline:DaeSpline = geometry.splines[i];
						
						for(j = 0; j < spline.vertices.length; j++)
						{
							k = (j+1) % spline.vertices.length;
							
							var v0:Vertex = new Vertex(spline.vertices[j][0], spline.vertices[j][1], spline.vertices[j][2]);
							var v1:Vertex = new Vertex(spline.vertices[k][0], spline.vertices[k][1], spline.vertices[k][2]);
						
							var line:Line = new Line(v0, v1,lineMaterial);
							
							lines.addLine(line);
						}
					}
					
					_geometries[geometry.id] = lines;
				}
				
			}
		}
		
				
		/**
		 * 建立顶点
		 * 
		 * Builds vertices from a COLLADA mesh.
		 * 
		 * @param	mesh	The COLLADA mesh. @see org.ascollada.core.DaeMesh
		 * 
		 * @return	Array of Vertex3D
		 */
		private function buildVertices(mesh:DaeMesh):Array
		{
			var vertices:Array = new Array();
			for( var i:int = 0; i < mesh.vertices.length; i++ )
				vertices.push(new Vertex(mesh.vertices[i][0], mesh.vertices[i][1], mesh.vertices[i][2]));
			return vertices;
		}
		
		/**
		 * 建立面
		 */
		private function buildFaces(primitive:DaePrimitive, geometry:Geometry, voffset:uint):void
		{
			var faces:Array = new Array();
			var material:IMaterial = this.materials.getMaterialBySymbol(primitive.material);
			
			material = material ? material : new ColorMaterial( Math.random() * 0xffffff );
			
			var instanceMaterial : DaeInstanceMaterial = _bindVertexInputs[ material ];
			
			// retreive correct texcoord-set for the material.
			var setID:int = 0;
			var textureSet:String = _textureSets[primitive.material];
			var geom:DaeGeometry = primitive.mesh.geometry;
			
			if( textureSet && textureSet.length && geom )
			{
				var instGeom:DaeInstanceGeometry = this.document.getDaeInstanceGeometry( geom.id );
				if( instGeom )
				{
					var vinput:DaeBindVertexInput = instGeom.findBindVertexInput( primitive.material, textureSet );
					if( vinput )
					{
						trace( "using input set #" + vinput.input_set + " for material " + primitive.material );
						setID = vinput.input_set;
					}
				}
			}
			
			var texCoordSet:Array = primitive.getTexCoords(setID); 
			var texcoords:Array = new Array();
			var i:int, j:int = 0, k:int;

			// texture coords
			for( i = 0; i < texCoordSet.length; i++ ) 
				texcoords.push(new Point(texCoordSet[i][0], 1 - texCoordSet[i][1]));
			
			var hasUV:Boolean = (texcoords.length == primitive.vertices.length);

			var idx:Array = new Array();
			var v:Array = new Array();
			var uv:Array = new Array();
		
			switch( primitive.type ) 
			{
				// Each line described by the mesh has two vertices. The first line is formed 
				// from first and second vertices. The second line is formed from the third and fourth 
				// vertices and so on.
				case ASCollada.DAE_LINES_ELEMENT:
					for( i = 0; i < primitive.vertices.length; i += 2 ) 
					{
						v[0] = geometry.vertices[ primitive.vertices[i] ];
						v[1] = geometry.vertices[ primitive.vertices[i+1] ];
						uv[0] = hasUV ? texcoords[  i  ] : new Point();
						uv[1] = hasUV ? texcoords[ i+1 ] : new Point();
						//geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[1]], material, [uv[0], uv[1], uv[1]]) );
					}
					break;
					
				// simple triangles
				case ASCollada.DAE_TRIANGLES_ELEMENT:
					for(i = 0, j = 0; i < primitive.vertices.length; i += 3, j++) 
					{
						idx[0] = voffset + primitive.vertices[i];
						idx[1] = voffset + primitive.vertices[i+1];
						idx[2] = voffset + primitive.vertices[i+2];
						
						v[0] = geometry.vertices[ idx[0] ];
						v[1] = geometry.vertices[ idx[1] ];
						v[2] = geometry.vertices[ idx[2] ];
						
						uv[0] = hasUV ? texcoords[ i+0 ] : new Point();
						uv[1] = hasUV ? texcoords[ i+1 ] : new Point();
						uv[2] = hasUV ? texcoords[ i+2 ] : new Point();
				
						geometry.triangles.push(new Triangle(v[2], v[1], v[0], material, [uv[2], uv[1], uv[0]]));
					}
					break;
				// polygon with *no* holes
				case ASCollada.DAE_POLYLIST_ELEMENT:
					for( i = 0, k = 0; i < primitive.vcount.length; i++ ) 
					{
						var poly:Array = new Array();
						var uvs:Array = new Array();
						
						for( j = 0; j < primitive.vcount[i]; j++ ) 
						{
							uvs.push( (hasUV ? texcoords[ k ] : new Point()) );
							poly.push( geometry.vertices[primitive.vertices[k++]] );
						}
						
						if( !geometry || !geometry.triangles || !geometry.vertices )
							throw new Error( "no geometry" );
							
						v[0] = poly[0];
						uv[0] = uvs[0];

						for( j = 1; j < poly.length - 1; j++ )
						{
							v[1] = poly[j];
							v[2] = poly[j+1];
							uv[1] = uvs[j];
							uv[2] = uvs[j+1];
							
							if( v[0] is Vertex && v[1] is Vertex && v[2] is Vertex )
							{
								geometry.triangles.push(new Triangle(v[2], v[1], v[0], material, [uv[2], uv[1], uv[0]]));
							}
							else
							{
								trace("" +primitive.name+ " "+ poly.length +" "+primitive.vertices.length+" "+geometry.vertices.length);
							}
						}
					}
					break;
				
				// polygons *with* holes (but holes not yet processed...)
				case ASCollada.DAE_POLYGONS_ELEMENT:
					for(i = 0, k = 0; i < primitive.polygons.length; i++)
					{
						var p:Array = primitive.polygons[i];
						var np:Array = new Array();
						var nuv:Array = new Array();
						
						for(j = 0; j < p.length; j++)
						{
							nuv.push( (hasUV ? texcoords[ k ] : new Point()) );
							np.push( geometry.vertices[primitive.vertices[k++]] );
						}
						
						v[0] = np[0];
						uv[0] = nuv[0];
						
						for(j = 1; j < np.length - 1; j++)
						{
							v[1] = np[j];
							v[2] = np[j+1];
							uv[1] = nuv[j];
							uv[2] = nuv[j+1];
				
							geometry.triangles.push(new Triangle(v[2], v[1], v[0], material, [uv[2], uv[1], uv[0]]));
						}
					}
					break;
						
				default:
					throw new Error("Don't know how to create face for a DaePrimitive with type = " + primitive.type);
			}
		}	
		
		/**
		 * 建立颜色
		 */
		private function buildColor( rgb:Array ):uint
		{
			var r:uint = rgb[0] * 0xff;
			var g:uint = rgb[1] * 0xff;
			var b:uint = rgb[2] * 0xff;
			return (r<<16|g<<8|b);
		}
		
		/**
		 * 建立结点
		 * 
		 * Builds a DisplayObject3D from a node. @see org.ascollada.core.DaeNode
		 * 
		 * @param	node	
		 * 
		 * @return	The created DisplayObject3D. @see org.papervision3d.objects.DisplayObject3D
		 */ 
		private function buildNode(node:DaeNode, parent:DisplayObject3D):void
		{
			var instance:DisplayObject3D;
			var material:IMaterial;
			var i:int;
			
			if(node.controllers.length)
			{
				// controllers, can be of type 'skin' or 'morph'
				for(i = 0; i < node.controllers.length; i++)
				{
					var instanceController:DaeInstanceController = node.controllers[i];
					var colladaController:DaeController = document.controllers[instanceController.url];

					if(colladaController.skin)
					{
						instance = new Skin(node.name);
						
						buildSkin(instance as Skin, colladaController.skin, instanceController.skeletons, node);
					}
					else if(colladaController.morph)
					{
						throw new Error("morph!");
					}
					else
						throw new Error("A COLLADA controller should be of type <skin> or <morph>!");
				
					// dunnu yet how to handle multiple controllers.
					break;
				}
			}
			else if(node.geometries.length)
			{
				// got geometry, so create a TriangleMesh3D
				instance = new DisplayObject3D(node.name);
				
				// add all COLLADA geometries to the TriangleMesh3D
				for each(var geom:DaeInstanceGeometry in node.geometries)
				{
					if(!_geometries[ geom.url ])
						continue;
					
					if(_geometries[ geom.url ] is Lines)
					{
						instance.addLines( _geometries[ geom.url ] );
						continue;
					}
					
					var geometry:Geometry = _geometries[ geom.url ];
							
					var materialInstances:Array = new Array();
					if(geom.materials)
					{
						for each(var instanceMaterial:DaeInstanceMaterial in geom.materials)
						{
							if(useMaterialTargetName){
								material = this.materials.getMaterialBySymbol(instanceMaterial.target);
							}else{
								material = this.materials.getMaterialBySymbol(instanceMaterial.symbol);
							}
							
							if(material)
							{
								_bindVertexInputs[ material ] = instanceMaterial;
								materialInstances.push(material);
							}
						}
					}
					
					mergeGeometries(instance, geometry.clone() as Geometry , materialInstances);
				}
			}
			else
			{
				// no geometry, simply create a Joint3D
				instance = new DisplayObject3D(node.name);
			}
			
			trace( instance );
			
			// recurse node instances
			for(i = 0; i < node.instance_nodes.length; i++)
			{
				var dae_node:DaeNode = document.getDaeNodeById(node.instance_nodes[i].url);
				buildNode(dae_node, instance);
			}
			
			// setup the initial transform
			instance.copyTransform( buildMatrix(node) );
			
			// recurse node children
			for(i = 0; i < node.nodes.length; i++)
				buildNode(node.nodes[i], instance);
			
			// save COLLADA id, sid
			_colladaID[instance] = node.id;
			_colladaSID[instance] = node.sid;
			_colladaIDToObject[node.id] = instance;
			_colladaSIDToObject[node.sid] = instance;
			_objectToNode[instance] = node;
				
			parent.addChild(instance);
		}
		
		/**
		 * 建立结点变换数组
		 * 
		 * Builds a Matrix3D from a node's transform array. @see org.ascollada.core.DaeNode#transforms
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMatrix(node:DaeNode):Matrix3D 
		{
			var stack:Array = buildMatrixStack(node);
			var matrix:Matrix3D = new Matrix3D();
			
			for( var i:int = 0; i < stack.length; i++ ) 
				matrix.prepend(stack[i]);
			
			return matrix;
		}
		
		/**
		 * 建立结点变换数组集
		 * 
		 * @param	node
		 * @return
		 */
		private function buildMatrixStack(node:DaeNode):Array
		{
			var stack:Array = new Array();	
			for( var i:int = 0; i < node.transforms.length; i++ ) 
				stack.push(buildMatrixFromTransform(node.transforms[i]));
			return stack;
		}
		
				
		/**
		 * 从变换提取数组
		 * 
		 * @param	node
		 * @return
		 */
		private function buildMatrixFromTransform(transform:DaeTransform):Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			var v:Array = transform.values;
			
			switch(transform.type)
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					matrix.appendRotation( v[3],new Vector3D( v[0], v[1], v[2] ));
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					matrix.appendScale(v[0], v[1], v[2]);
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					matrix.appendTranslation(v[0], v[1], v[2]);
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					matrix.rawData = toVectorForMatrix(v);
					break;
				default:
					throw new Error("Unknown transform type: " + transform.type);
			}
			
			return matrix;
		}
		
		/**
		 * 数组转化成矩阵矢量.
		 */
		private function toVectorForMatrix( v:Array ):Vector.<Number>
		{
			if( v && v.length >= 12 )
			{
				if( v.length == 16 )
				{
					return Vector.<Number>([v[0],v[4],v[8],v[12],v[1],v[5],v[9],v[13],v[2],v[6],v[10],v[14],v[3],v[7],v[11],v[15]]);
				}
				
				return Vector.<Number>([v[0],v[4],v[8],0,v[1],v[5],v[9],0,v[2],v[6],v[10],0,v[3],v[7],v[11],1]);
			}
			
			return Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
		}
		
		/**
		 * 建立骨骼
		 * 
		 * Builds a skin.
		 * 
		 * @param	instance
		 * @param	colladaSkin
		 * @param	skeletons
		 */ 
		private function buildSkin(instance:Skin, colladaSkin:DaeSkin, skeletons:Array, node:DaeNode):void
		{
			var skin:Geometry = _geometries[ colladaSkin.source ];
			if(!skin)
			{
				// geometry can be inside a morph controller
				var morphController:DaeController = this.document.controllers[colladaSkin.source];
				if(morphController && morphController.morph)
				{
					var morph:DaeMorph = morphController.morph;
					
					// fetch geometry
					skin = _geometries[morph.source];

					// fetch target geometries
					for(var j:int = 0; j < morph.targets.length; j++)
					{
						var targetGeometry:Geometry = _geometries[morph.targets[j]];
					}
				}
				if(!skin)
					throw new Error("no geometry for source: " + colladaSkin.source);
			}
			
			mergeGeometries(instance, skin.clone() as Geometry );
			
			_skins[ instance ] = colladaSkin;
		}
		
				
		/**
		 * 合并几何体
		 * 
		 * Merge geometries.
		 * 
		 * @param target The target geometry to merge to.
		 * @param source The source geometry
		 * @param material Optional material for triangles, only used when a triangle has no material.
		 */ 
		private function mergeGeometries(target:DisplayObject3D, source:Geometry, materialInstances:Array=null):void
		{
			if(materialInstances && materialInstances.length)
			{
				var firstMaterial:IMaterial = materialInstances[0];
				
				for each(var triangle:Triangle in source.triangles)
				{
					var correctMaterial:Boolean = false;
					for each(var material:IMaterial in materialInstances)
					{
						if(material === triangle.material)
						{
							correctMaterial = true;
							break;
						}
					}
					triangle.material = correctMaterial ? triangle.material : firstMaterial;
				}
			}
			
			target.merge( source );
		}
		
				
		/**
		 * 安装骨骼控制器.
		 * Setup the skin controllers.
		 */ 
		private function linkSkins():void
		{
			_numSkins = 0;
			
			for(var object:* in _skins)
			{
				var instance:Skin = object as Skin;
				if(!instance)
					throw new Error("Not a Skin?");
				linkSkin(instance, _skins[object]);
				_numSkins++;
			}
		}
		
		/**
		 * 安装骨骼控制器.
		 * Setup the skin controllers.
		 */ 
		protected function linkSkin(instance:Skin, skin:DaeSkin):void
		{			
			var i:int;
			var found:Object = new Object();
			
			var controller:SkinController = new SkinController(instance);

			controller.bindShapeMatrix = new Matrix3D(toVectorForMatrix(skin.bind_shape_matrix));
			controller.joints = new Array();
			controller.vertexWeights = new Array();
			controller.invBindMatrices = new Array();
			
			for(i = 0; i < skin.joints.length; i++)
			{
				var jointId:String = skin.joints[i];
				
				if(found[jointId])
					continue;
					
				var joint:DisplayObject3D = _colladaIDToObject[jointId];
				if(!joint)
					joint = _colladaSIDToObject[jointId];
				if(!joint)
					throw new Error("Couldn't find the joint id = " + jointId);

				var vertexWeights:Array = skin.findJointVertexWeightsByIDOrSID(jointId);
				if(!vertexWeights)
					throw new Error("Could not find vertex weights for joint with id = " + jointId);
					
				var bindMatrix:Array = skin.findJointBindMatrix2(jointId);
				if(!bindMatrix || bindMatrix.length != 16)
					throw new Error("Could not find inverse bind matrix for joint with id = " + jointId);
				
				controller.joints.push(joint);
				controller.invBindMatrices.push(new Matrix3D(toVectorForMatrix(bindMatrix)));
				controller.vertexWeights.push(vertexWeights);
				
			}
			
			addController( controller );
		}
		
		/**
		 * Called on parse animations progress.
		 * 
		 * @param	event
		 */ 
		private function onParseAnimationsProgress(event:ProgressEvent):void
		{
			trace( "animations #" + event.bytesLoaded + " of " + event.bytesTotal);
		}
			
		/**
		 * 动画读取完成时调用
		 * 
		 * Called when the parser completed parsing animations.
		 * 
		 * @param	event
		 */ 
		private function onParseAnimationsComplete(event:Event):void
		{
			this.parser.removeEventListener(ProgressEvent.PROGRESS,onParseAnimationsProgress );
			
			buildAnimationChannels();

			animations = new AnimationController(loop);
			
			animations.name = "animations";
			
			var channels:Array = getAnimationChannels();
			
			for each(var channel:AnimationChannel in channels)
			{
				animations.addChannel( channel );
			}

			addController( animations );

			trace( animations );
			
			if( autoPlay )
			{
				animations.play();
			}

		}
		
		/**
		 * 建立动画控制器
		 * 
		 * Build all animation channels.
		 */
		private function buildAnimationChannels():void
		{
			var target:DisplayObject3D;
			var channel:DaeChannel;
			var channelsByObject:Dictionary = new Dictionary(true);
			var i:int;
			
			_channelsByTarget = new Dictionary(true);
			
			for each(var animation:DaeAnimation in this.document.animations)
			{
				for(i = 0; i < animation.channels.length; i++)
				{
					channel = animation.channels[i];
					
					target = _colladaIDToObject[channel.syntax.targetID];
					if(!target)
						throw new Error("damn");
						
					if(!channelsByObject[target])
						channelsByObject[target] = new Array();
					
					channelsByObject[target].push(channel);
				}
			}
			
			for(var object:* in channelsByObject)
			{
				target = object as DisplayObject3D;
							
				var channels:Array = channelsByObject[object];
				var node:DaeNode = _objectToNode[target];
					
				if(!node)
					throw new Error("Couldn't find the targeted object with name '" + node.name + "'");
					
				node.channels = channels;
				
				if(!channels.length)
					continue;
				
				channel = channels[0];
				
				var transform:DaeTransform = node.findMatrixBySID(channel.syntax.targetSID);
				
				if(!transform)
				{
					trace("Could not find a transform with SID=" + channel.syntax.targetSID);
					continue;
				}
	
				// the object has a single <matrix> channel
				if(channels.length == 1 && transform.type == ASCollada.DAE_MATRIX_ELEMENT)
				{
					_channelsByTarget[target] = [buildAnimationChannel(target, channel)];
					continue;
				}
				
				// the object has multiple channels, lets bake 'm into a single channel
				var allTimes:Array = new Array();
				var times:Array = new Array();
				var lastTime:Number;
				
				// fetch all times for all channels
				for each(channel in channels)
					allTimes = allTimes.concat(channel.input);
				allTimes.sort(Array.NUMERIC);
				
				// make array with unique times
				for(i = 0; i < allTimes.length; i++)
				{
					var t:Number = allTimes[i];
					if(i == 0)
						times.push(t);
					else if(t - lastTime > 0.01)
						times.push(t);
					lastTime = t;	
				}
				
				// build the MatrixChannel3D's for this object
				var mcs:Object = new Object();
				for each(channel in channels)
				{
					var animationChannel:MatrixChannel = buildAnimationChannel(target, channel);
					if(animationChannel) 
						mcs[ channel.syntax.targetSID ] = buildAnimationChannel(target, channel);
				}
					
				var bakedChannel:MatrixChannel = new MatrixChannel(target);
				
				// build a baked channel
				for(i = 0; i < times.length; i++)
				{
					var keyframeTime:Number = times[i];
					var bakedMatrix:Matrix3D = new Matrix3D();
					var position:Vector3D = new Vector3D();
					
					// loop over the DaeNode's transform-stack
					for(var j:int = 0; j < node.transforms.length; j++)
					{
						transform = node.transforms[j];
						
						var matrixChannel:MatrixChannel = mcs[ transform.sid ];
						
						if(matrixChannel)
						{
							// this transform is animated, so lets determine the matrix for the current keyframeTime
							var time:Number;
							if(keyframeTime < matrixChannel.startTime)
								time = 0;
							else if(keyframeTime > matrixChannel.endTime)
								time = 1;
							else
								time = keyframeTime / (matrixChannel.endTime - matrixChannel.startTime);
								
							// update the channel by time, so the matrix for the current keyframe is setup
							matrixChannel.goToTime(time);
							
							// bake the matrix
							bakedMatrix.prepend(target.transformMatrix);
						}
						else
						{
							// this transform isn't animated, simply bake the transform into the matrix
							bakedMatrix.prepend(buildMatrixFromTransform(transform));
						}
					}
					
					// now we can add the baked matrix as a new keyframe
					bakedChannel.addKeyFrame(new KeyFrame("frame_" + i, keyframeTime, bakedMatrix));
				}
				
				_channelsByTarget[target] = [bakedChannel];
			}
		}
				
		/**
		 * 建立单个动画控制器
		 * 
		 * Builds a animation channel for an object.
		 * 
		 * @param	matrixStackChannel	the target object's channel
		 * @param	target	The target object
		 * @param	channel	The DaeChannel
		 */ 
		private function buildAnimationChannel(target:DisplayObject3D, channel:DaeChannel):MatrixChannel
		{				
			var node:DaeNode = _objectToNode[target];
					
			if(!node)
				throw new Error("Couldn't find the targeted object!");
					
			var matrixChannel:MatrixChannel = new MatrixChannel(target, channel.syntax.targetSID);
			
			var transform:DaeTransform = node.findMatrixBySID(channel.syntax.targetSID);
					
			if(!transform)
			{
				trace("Couldn't find the targeted object's transform: " + channel.syntax.targetSID);
				return null;
			}
			
			var matrix:Matrix3D = new Matrix3D();
			var data:Array;
			var val:Number;
			var i:int;

			switch(transform.type)
			{
				case "matrix":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							matrix.rawData = toVectorForMatrix( channel.output[i] );
							matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
						}
					}
					else if(channel.syntax.isArrayAccess)
					{
						var arrayMember:String = channel.syntax.arrayMember.join("");
						var matrixProp:uint;
						var rawData:Vector.<Number> = target.transformMatrix.rawData;
												
						switch(arrayMember)
						{
							case "(0)(0)":
								matrixProp = 0;
								break;
							case "(0)(1)":
								matrixProp = 1;
								break;
							case "(0)(2)":
								matrixProp = 2;
								break;
							case "(0)(3)":
								matrixProp = 3;
								break;
							case "(1)(0)":
								matrixProp = 4;
								break;
							case "(1)(1)":
								matrixProp = 5;
								break;
							case "(1)(2)":
								matrixProp = 6;
								break;
							case "(1)(3)":
								matrixProp = 7;
								break;
							case "(2)(0)":
								matrixProp = 8;
								break;
							case "(2)(1)":
								matrixProp = 9;
								break;
							case "(2)(2)":
								matrixProp = 10;
								break;
							case "(2)(3)":
								matrixProp = 11;
								break;
							case "(3)(0)":
								matrixProp = 12;
								break;
							case "(3)(1)":
								matrixProp = 13;
								break;
							case "(3)(2)":
								matrixProp = 14;
								break;
							case "(3)(3)":
								matrixProp = 15;
								break;
							default:
								throw new Error(arrayMember);
						}
								
						for(i = 0; i < channel.input.length; i++)
						{
							//matrix.identity();                      // ---------------------------------
							rawData[matrixProp] = channel.output[i];
							matrix.rawData = rawData;
							matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}
					break;
				case "rotate":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							data = channel.output[i];
							matrix.identity();
							matrix.appendRotation( data[3],new Vector3D( data[0], data[1], data[2]) );
							matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
						}
					}
					else if(channel.syntax.isDotAccess)
					{
						switch(channel.syntax.member)
						{
							case "ANGLE":
								for(i = 0; i < channel.input.length; i++)
								{
									matrix.identity();
									matrix.appendRotation( channel.output[i],new Vector3D( transform.values[0], transform.values[1], transform.values[2] ) );
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
								}
								break;
							default:
								throw new Error("Don't know how to handle this channel: " + channel.syntax);
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}	
					break;
				case "scale":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							matrix.identity();
							data = channel.output[i];
							matrix.appendScale(data[0], data[1], data[2]);
							matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
						}
					}
					else if(channel.syntax.isDotAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							matrix.identity();
							val = channel.output[i];
							switch(channel.syntax.member)
							{
								case "X":
									matrix.appendScale(val, 0, 0);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								case "Y":
									matrix.appendScale(0, val, 0);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								case "Z":
									matrix.appendScale(0, 0, val);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								default:
									break;		
							}
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}
					break;
				case "translate":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							matrix.identity();
							data = channel.output[i];
							matrix.appendTranslation(data[0], data[1], data[2]);
							matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
						}
					}	
					else if(channel.syntax.isDotAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							matrix.identity();
							val = channel.output[i];
							switch(channel.syntax.member)
							{
								case "X":
									matrix.appendTranslation(val, 0, 0);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								case "Y":
									matrix.appendTranslation(0, val, 0);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								case "Z":
									matrix.appendTranslation(0, 0, val);
									matrixChannel.addKeyFrame(new KeyFrame("keyframe_" + i, channel.input[i], matrix.clone()));
									break;
								default:
									break;		
							}
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}		
					break;
				default:
					throw new Error("Unknown transform type!");	
			}
				
			return matrixChannel;
		}
		
		/**
		 * 获取动画控制器
		 * 
		 * Gets all animation channels for a target. 
		 * <p>NOTE: when target is null, all channels for this object are returned.</p>
		 * 
		 * @param	target	The target to get the channels for.
		 * 
		 * @return	Array of AnimationChannel3D.
		 */ 
		public function getAnimationChannels(target:DisplayObject3D=null):Array
		{
			var channels:Array = new Array();
			if(target == null)
			{
				for each(var array:Array in _channelsByTarget)
					channels = channels.concat(array);
			}
			else if(_channelsByTarget[target])
			{
				channels = channels.concat(_channelsByTarget[target]);
			}
			else
				return null;
					
			return channels;
		}
		
		/** Whether the COLLADA uses Y-up, Z-up otherwise. */
		public function get yUp():Boolean
		{
			if(this.document){
				return (this.document.asset.yUp == ASCollada.DAE_Y_UP);
			}else{
				return false;
			}
		}
		
		private var loop:Boolean;
		
		private var autoPlay:Boolean;
	}
}
