package ssg
{
	public class SSGTraceTriangle
	{
		public function SSGTraceTriangle()
		{
		}
		
		public function CreateFromVector ( points : Vector.<Number>, o0 : uint, o1 : uint, o2 : uint ) {
			// calc edges and normal
			var e1x : Number = points[o1+0] - points[o0+0];
			var e1y : Number = points[o1+1] - points[o0+1];
			var e1z : Number = points[o1+2] - points[o0+2];
			// e2=p2-p0		
			var e2x : Number = points[o2+0] - points[o0+0];
			var e2y : Number = points[o2+1] - points[o0+1];
			var e2z : Number = points[o2+2] - points[o0+2];
			// n=e1 x e2
			var nx : Number = e1y*e2z - e1z*e2y;
			var ny : Number = e1z*e2x - e1x*e2z;
			var nz : Number = e1x*e2y - e1y*e2x;
			
			if ( nx<0 ) nx=-nx;
			if ( ny<0 ) ny=-ny;
			if ( nz<0 ) nz=-nz;
			if ( nx > ny ) {
				if ( nx > nz ) {
					k = 0;
					// k=0; u=1, v=2
	
				} else {
					k = 2;
					// k=2; u=0, v=1
				}
			}  else {
				if ( ny > nz ) {
					k = 1;
					// k=1, u=2, v=0
				} else {
					k = 2;
					// k=2, u=0, v=1
				}
			}					
		}
		
		public function Intersect ( ray : SSGPickRay ) : Boolean {
			var nd : Number, f : Number, hu : Number, hv : Number;
			if ( k==0 ) {
				nd = 1.0 / (ray.dx + n_u * ray.dy + n_v * ray.dz );
				f = (n_d-ray.ox - n_u*ray.oy - n_v*ray.oz) * nd; 				
				hu = ray.oy + f * ray.dy;
				hv = ray.oz + f * ray.dz;
			} else {
				if ( k==1 ) {
					nd = 1.0 / (ray.dy + n_u * ray.dz + n_v * ray.dx );
					f = (n_d-ray.oy - n_u*ray.oz - n_v*ray.ox) * nd; 					
					hu = ray.oz + f * ray.dz;
					hv = ray.ox + f * ray.dx;
				} else { //k==2
					nd = 1.0 / (ray.dz + n_u * ray.dx + n_v * ray.dy );
					f = (n_d-ray.oz - n_u*ray.ox - n_v*ray.oy) * nd; 					
					hu = ray.ox + f * ray.dx;
					hv = ray.oy + f * ray.dy;				
				}
			}

			if ( !(ray.thit>f && t>eps ) ) return false;		
			var lambda : Number = hu * b_nu + hv * b_nv + b_d; 
			if ( lambda < 0 ) return false;
			var mue : Number = hu * c_nu + hv * c_nv + c_d;
			if ( mue < 0 ) return false;
			if ( lambda+mue > 1 ) return false;
			
			ray.thit = f;
			ray.uhit = lambda;
			ray.vhit = mue; 				
			return true;			
		}
		
		var k : uint;
		var n_u : Number, n_v : Number, n_d : Number;
		var b_nu : Number, b_nv : Number, b_d : Number;
		var c_nu : Number, c_nv : Number, c_d : Number; 
	}
}