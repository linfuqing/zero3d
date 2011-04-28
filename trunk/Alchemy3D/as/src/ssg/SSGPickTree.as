package ssg
{
	import __AS3__.vec.Vector;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class SSGPickTree
	{
		public function SSGPickTree()
		{
		}
		
		public function CountNodes ( leafonly : Boolean ) : uint {
			if ( root==null ) return 0;
			return root.CountNodes(leafonly);
		}
		
		public function Create ( vertices : Vector.<Number>, npv : uint, indices : Vector.<uint>, maxdepth : uint, minsplit : uint ) : void {
			// blocking version 
			CreateBegin ( vertices, npv, indices, maxdepth, minsplit );
			while ( CreateContinue(1000)!=0 ) { } 
		}
		
		public function CreateInTimer ( vertices : Vector.<Number>, npv : uint, indices : Vector.<uint>, maxdepth : uint, minsplit : uint ) : void {
			if ( createtimer != null ) createtimer.stop();
			else createtimer = new Timer(10,10000);			
			CreateBegin ( vertices, npv, indices, maxdepth, minsplit );			
			createtimer.addEventListener(TimerEvent.TIMER, CreateTimerFunc );
			createtimer.start();	
		}
		
		private function CreateTimerFunc ( e : Event ) : void {
			if ( CreateContinue(10)==0 ) {
				createtimer.stop();
				createtimer = null;
			} 
		}
		
		public function CreateBegin ( vertices : Vector.<Number>, npv : uint, indices : Vector.<uint>, maxdepth : uint, minsplit : uint ) : void {
			// create one node 				
			root = new SSGPickTreeNode();
			root.leaf = new Array();
			for ( var i:uint = 0; i<indices.length; i++ ) root.leaf.push ( indices[i]*npv );
			
			var maxx : Number = vertices[root.leaf[0]+0]; var minx : Number = maxx;
			var maxy : Number = vertices[root.leaf[0]+1]; var miny : Number = maxy;
			var maxz : Number = vertices[root.leaf[0]+2]; var minz : Number = maxz;
			for ( i=1; i<root.leaf.length; i++ ) {
				if ( vertices[root.leaf[i]+0]>maxx ) maxx = vertices[root.leaf[i]+0]; if ( vertices[root.leaf[i]+0]<minx ) minx = vertices[root.leaf[i]+0];
				if ( vertices[root.leaf[i]+1]>maxy ) maxy = vertices[root.leaf[i]+1]; if ( vertices[root.leaf[i]+1]<miny ) miny = vertices[root.leaf[i]+1];
				if ( vertices[root.leaf[i]+2]>maxz ) maxz = vertices[root.leaf[i]+2]; if ( vertices[root.leaf[i]+2]<minz ) minz = vertices[root.leaf[i]+2]; 
			}			
			// start
			useverts = vertices;
			usemaxdepth = maxdepth;
			useminsplit = minsplit;
					
			stack = new Array();			
			stack.push(new SSGPickTreeNodeSubdivState(root,0,minx, maxx, miny, maxy, minz, maxz) );
		}
		
		public function CreateContinue ( n : uint ) : uint {
			if ( stack==null ) return 0;
			while ( stack.length>0 && n>0 ) {
				var state : SSGPickTreeNodeSubdivState = stack.pop();
				state.node.Subdivide ( this, useverts, state );
				
				n--;
			}
			if ( stack.length==0 ) {
				stack = null;
				return 0;				
			}
			return stack.length;
		}
		
		public function Intersect ( ray : SSGPickRay, vertices : Vector.<Number>, hit : SSGNode ) : void {
			if ( root == null ) return;
			//var startnode = root.FindNode ( ray.ox, ray.oy, ray.oz );			
			root.Intersect ( ray, vertices, hit, 0, ray.thit ) 
		}

		private var root : SSGPickTreeNode;
		
		public var stack : Array;
		public var useverts : Vector.<Number>;
		public var usemaxdepth : uint;
		public var useminsplit : uint;
		
		private var createtimer : Timer;
	}
	
}

{
	
class SSGPickTreeNode {
	public var leaf : Array;
	// only for inner 
	public var axis : uint;
	public var d : Number;
	public var left : SSGPickTreeNode;
	public var right : SSGPickTreeNode;	
	
	public function CountNodes ( leafonly : Boolean ) : uint {
		if ( leaf!=null ) return 1;		
		return left.CountNodes(leafonly) + right.CountNodes(leafonly) + (leafonly?0:1);			
	}
	
	private function IntersectAxis ( oray : Number, dray : Number, ray : ssg.SSGPickRay, vertices : Vector.<Number>, hit : ssg.SSGNode, t0 : Number, t1 : Number ) : Boolean {
		var ps0 : Number = dray * t0 + oray; // the side we start on
		var ps1 : Number = dray * t1 + oray; // the side we end on
		var nearnode : SSGPickTreeNode = ps0<=d?left:right;
		var farnode : SSGPickTreeNode = ps1<=d?left:right;
		
		if ( farnode == nearnode ) 
			return farnode.Intersect(ray,vertices,hit,t0,t1);		
						
		var tplane : Number = (d-oray) / dray; // the intersection of the split plane and the ray
				
		if ( nearnode.Intersect ( ray, vertices, hit, t0, tplane ) ) return true;
		return farnode.Intersect ( ray, vertices, hit, tplane, t1);								
	}
	
	public function Intersect ( ray : ssg.SSGPickRay, vertices : Vector.<Number>, hit : ssg.SSGNode, t0 : Number, t1 : Number ) : Boolean {
		if ( !(t0<t1) ) return false;
		
		if ( leaf!=null ) {
			var didhit : Boolean = false;
			// really only intersect in t0..t1 if we need accurate t results (that is, if we need to gurantee closest t)
			for ( var i : uint = 0; i<leaf.length; i+=3 ) 
				if ( ray.IntersectTriangle_HM(vertices,leaf[i], leaf[i+1], leaf[i+2], hit ) ) didhit = true;
			return didhit; 
		} else {
			// figure out where to go to first, and if to go there
			
			if ( axis==0 ) return IntersectAxis ( ray.ox, ray.dx, ray, vertices, hit, t0, t1 );
			if ( axis==1 ) return IntersectAxis ( ray.oy, ray.dy, ray, vertices, hit, t0, t1 );
			if ( axis==2 ) return IntersectAxis ( ray.oz, ray.dz, ray, vertices, hit, t0, t1 );
			
			return false;					
		}
	}
	
	public function FindNode ( x : Number, y : Number, z : Number ) : SSGPickTreeNode {
		if ( leaf!=null ) return this; 
		if ( axis==0 ) {
			if ( x <= d ) return left.FindNode(x,y,z);
			else return right.FindNode(x,y,z);
		}
		if ( axis==1 ) {
			if ( y <= d ) return left.FindNode(x,y,z);
			else return right.FindNode(x,y,z);
		}
		if ( axis==2 ) {
			if ( z <= d ) return left.FindNode(x,y,z);
			else return right.FindNode(x,y,z);
		}
		return null;
	}
	
	public function Subdivide ( caller : ssg.SSGPickTree, vertices : Vector.<Number>, state : SSGPickTreeNodeSubdivState ) : void {		
		if ( caller.usemaxdepth<=state.depth || caller.useminsplit>=leaf.length ) return; // done
		// compute bounds ( this should be tracked... :/)
		var i : uint;
		
		var leftx : Number = state.maxx; var lefty : Number = state.maxy; var leftz : Number = state.maxz;
		var rightx : Number = state.minx; var righty : Number = state.miny; var rightz : Number = state.minz;
		// split median along longest axis
		if ( state.maxx - state.minx > state.maxy - state.miny ) {
			if ( state.maxx - state.minx > state.maxz - state.minz ) {
				axis = 0;
				d = (state.maxx + state.minx)*.5;
				leftx = d; rightx = d;
			} else {
				axis = 2;
				d = (state.maxz + state.minz)*.5;
				leftz = d; rightz = d;
			}
		} else {
			if ( state.maxy - state.miny > state.maxz - state.minz ) {
				axis = 1;
				d = (state.maxy + state.miny)*.5;
				lefty = d; righty = d;
			} else {
				axis = 2;
				d = (state.maxz + state.minz)*.5;
				leftz = d; rightz = d;
			}			
		}
		//trace ( "Depth: "+maxdepth.toString()+" n= "+(leaf.length/3).toString() ); 
		//trace ( " Split axis: "+axis.toString()+" d= "+d.toString() );
		
		// assign tris to new leaves
		left = new SSGPickTreeNode ( );
		left.leaf = new Array();		
		right = new SSGPickTreeNode ( );
		right.leaf = new Array();				
		
		var nleft : uint = 0;
		var nright : uint = 0;
		
		for ( i=0; i<leaf.length; i+=3 ) {
			var goleft : Boolean = false;
			var goright : Boolean = false;									
			if ( vertices[leaf[i+0]+axis] <= d ) goleft = true; 
			if ( vertices[leaf[i+0]+axis] >= d ) goright = true;
			if ( vertices[leaf[i+1]+axis] <= d ) goleft = true; 
			if ( vertices[leaf[i+1]+axis] >= d ) goright = true;
			if ( vertices[leaf[i+2]+axis] <= d ) goleft = true; 
			if ( vertices[leaf[i+2]+axis] >= d ) goright = true;			 
			if ( goleft ) { nleft++; left.leaf.push(leaf[i]); left.leaf.push(leaf[i+1]); left.leaf.push(leaf[i+2]); }
			if ( goright ) { nright++; right.leaf.push(leaf[i]); right.leaf.push(leaf[i+1]); right.leaf.push(leaf[i+2]); } 
		}		
		if ( nleft==leaf.length/3 && nright==leaf.length/3 ) { // bad split
			right = null;
			left = null;
		} else {
			leaf = null;	
			//trace ( " Left: "+nleft.toString()+" Right: "+nright.toString() );
			caller.stack.push ( new SSGPickTreeNodeSubdivState(left,state.depth+1,state.minx, leftx, state.miny, lefty, state.minz, leftz) );
			caller.stack.push ( new SSGPickTreeNodeSubdivState(right,state.depth+1,rightx, state.maxx, righty, state.maxy, rightz, state.maxz) );			
		}					
	}
	
	
}

class SSGPickTreeNodeSubdivState {
	public function SSGPickTreeNodeSubdivState ( _node : SSGPickTreeNode, _depth : uint, _minx : Number, _maxx : Number, _miny : Number, _maxy : Number, _minz : Number, _maxz : Number ) {
		minx = _minx; maxx = _maxx; miny = _miny; maxy = _maxy; minz = _minz; maxz = _maxz;
		depth = _depth;
		node = _node;
	} 
	public var minx : Number, maxx : Number, miny : Number, maxy : Number, minz : Number, maxz : Number;
	public var depth : uint;		
	public var node : SSGPickTreeNode; 	
}

}