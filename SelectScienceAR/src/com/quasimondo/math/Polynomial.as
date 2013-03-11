﻿package com.quasimondo.math
{
	public class Polynomial
	{
		public static const TOLERANCE:Number = 1e-6;
		public static const ACCURACY:Number = 6;
	
		public var coefs:Vector.<Number>;
		private var length:Number;
		public var degree:Number;
		
		public function Polynomial( ...arguments )
		{
			coefs = Vector.<Number>(arguments.slice());
			coefs.reverse();
			length = coefs.length;
			degree = length-1;
			 
		}
	
	
		public function evaluate( x:Number ):Number 
		{
			var result:Number = 0;
			for (var i:Number =length; --i>-1;) 
			{
				result = result * x + coefs[i];
			}
			return result;
		};
	
		public function mult( that:Polynomial ):Polynomial
		{
			var result:Polynomial = new Polynomial();
			var i:int, j:int;
			for ( i = 0; i<= degree + that.degree; i++) 
			{
				result.coefs.push(0);
			}
			for ( i = 0; i<=degree; i++) 
			{
				for ( j = 0; j<=that.degree; j++) 
				{
					result.coefs[int(i+j)] += coefs[i] * that.coefs[j];
				}
			}
			return result;
		};
	
		public function divide_scalar( scalar:Number ):void
		{
			for (var i:int = 0; i<length; i++) 
			{
				coefs[i] /= scalar;
			}
		};
		
		public function simplify():void
		{
			for (var i:int = degree; --i>-1; ) 
			{
				if ( Math.abs(coefs[i]) <= TOLERANCE ) 
				{
					coefs.pop();
					length--;
					degree--;
				} else {
					break;
				}
			}
		};
		
		public function bisection(min:Number, max:Number):Number
		{
			var minValue:Number = evaluate(min);
			var maxValue:Number = evaluate(max);
			var result:Number = NaN;
			
			if (Math.abs(minValue)<=TOLERANCE) 
			{
				result = min;
			} else if (Math.abs(maxValue)<=TOLERANCE) 
			{
				result = max;
			} else if (minValue*maxValue<=0) 
			{
				var tmp1:Number = Math.log(max-min);
				var tmp2:Number = Math.log(10)*ACCURACY;
				var iters:Number = Math.ceil((tmp1+tmp2)/Math.log(2));
				for (var i:Number = 0; i<iters; i++) {
					result = 0.5*(min+max);
					var value:Number = evaluate(result);
					if (Math.abs(value)<=TOLERANCE) {
						break;
					}
					if (value*minValue<0) {
						max = result;
						maxValue = value;
					} else {
						min = result;
						minValue = value;
					}
				}
			}
			return result;
		};
		
		public function toString():String
		{
			var coefs:Vector.<Number> = new Vector.<Number>();
			var signs:Vector.<String> = new Vector.<String>();
			var value:Number;
			var term:String;
			var i:int;
			for ( i = length; --i>-1; ) 
			{
				value = coefs[i];
				if (value != 0) {
					var sign:String = (value<0) ? " - " : " + ";
					value = Math.abs(value);
					term = String( value );
					if (i>0) {
						if (value == 1) {
							term = "x";
						} else {
							term += "x";
						}
					}
					if (i>1) {
						term += "^"+i;
					}
					signs.push(sign);
					coefs.push(term);
				}
			}
			signs[0] = (signs[0] == " + ") ? "" : "-";
			var result:String = "";
			for ( i = 0; i<length; i++) 
			{
				result += signs[i]+coefs[i];
			}
			return result;
		};
	
		public function getDerivative():Polynomial
		{
			var derivative:Polynomial = new Polynomial();
			for (var i:int = 1; i<length; i++) 
			{
				derivative.coefs.push(i*coefs[i]);
			}
			return derivative;
		};
	
		public function getRoots():Vector.<Number>
		{
			var result:Vector.<Number>;
			simplify();
			switch (degree) {
			case 0 :
				result = new Vector.<Number>();
				break;
			case 1 :
				result = getLinearRoot();
				break;
			case 2 :
				result = getQuadraticRoots();
				break;
			case 3 :
				result = getCubicRoots();
				break;
			case 4 :
				result = getQuarticRoots();
				break;
			default:
				result = new Vector.<Number>();
				break;
			}
			return result;
		};
	
		public function getRootsInInterval( min:Number, max:Number ):Vector.<Number> 
		{
			var roots:Vector.<Number> = new Vector.<Number>();
			var root:Number;
			if (degree == 1) {
				root = bisection( min, max);
				if (!isNaN(root)) {
					roots.push(root);
				}
			} else {
				var deriv:Polynomial = getDerivative();
				var droots:Vector.<Number> = deriv.getRootsInInterval(min, max);
				if (droots.length>0) {
					root = bisection(min, droots[0]);
					if (!isNaN(root)) {
						roots.push(root);
					}
					for (var i:int = 0; i<=droots.length-2; i++) {
						root = bisection(droots[i], droots[int(i+1)]);
						if (!isNaN(root)) {
							roots.push(root);
						}
					}
					root = bisection(droots[int(droots.length-1)], max);
					if (!isNaN(root)) {
						roots.push(root);
					}
				} else {
					root = bisection(min, max);
					if (!isNaN(root)) {
						roots.push(root);
					}
				}
		
			}
			return roots;
		};
	
		public function getLinearRoot():Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>();
			var a:Number = coefs[1];
			if (a != 0) 
			{
				result.push(-coefs[0]/a);
			}
			return result;
		};
	
		public function getQuadraticRoots():Vector.<Number>
		{
			var results:Vector.<Number> = new Vector.<Number>();
			if ( degree == 2 ) 
			{
				var a:Number = coefs[2];
				var b:Number = coefs[1]/a;
				var c:Number = coefs[0]/a;
				var d:Number = b*b-4*c;
				if (d>0) {
					var e:Number = Math.sqrt(d);
					results.push(0.5*(-b+e));
					results.push(0.5*(-b-e));
				} else if (d == 0) {
					results.push(0.5*-b);
				}
			}
			return results;
		};
	
		public function getCubicRoots():Vector.<Number>
		{
			var tmp:Number;
			
			var results:Vector.<Number> = new Vector.<Number>();
			if (degree == 3) 
			{
				var c3:Number = coefs[3];
				var c2:Number = coefs[2]/c3;
				var c1:Number = coefs[1]/c3;
				var c0:Number = coefs[0]/c3;
				var a:Number = (3*c1-c2*c2)/3;
				var b:Number = (2*c2*c2*c2-9*c1*c2+27*c0)/27;
				var offset:Number = c2/3;
				var discrim:Number = b*b/4+a*a*a/27;
				var halfB:Number = b/2;
				if (Math.abs(discrim)<=TOLERANCE) {
					discrim = 0;
				}
				if (discrim>0) {
					var e:Number = Math.sqrt(discrim);
					var root:Number;
					tmp = -halfB+e;
					if (tmp>=0) {
						root = Math.pow(tmp, 1/3);
					} else {
						root = -Math.pow(-tmp, 1/3);
					}
					tmp = -halfB-e;
					if (tmp>=0) {
						root += Math.pow(tmp, 1/3);
					} else {
						root -= Math.pow(-tmp, 1/3);
					}
					results.push(root-offset);
				} else if (discrim<0) {
					var distance:Number = Math.sqrt(-a/3);
					var angle:Number = Math.atan2(Math.sqrt(-discrim), -halfB)/3;
					var cos:Number = Math.cos(angle);
					var sin:Number = Math.sin(angle);
					var sqrt3:Number = Math.sqrt(3);
					results.push(2*distance*cos-offset);
					results.push(-distance*(cos+sqrt3*sin)-offset);
					results.push(-distance*(cos-sqrt3*sin)-offset);
				} else {
					if (halfB>=0) {
						tmp = -Math.pow(halfB, 1/3);
					} else {
						tmp = Math.pow(-halfB, 1/3);
					}
					results.push(2*tmp-offset);
					results.push(-tmp-offset);
				}
			}
			return results;
		};
	
	public function getQuarticRoots():Vector.<Number>
	{
		var d:Number, t2:Number, f:Number;
		var results:Vector.<Number> = new Vector.<Number>();
		if (degree == 4) {
			var c4:Number = coefs[4];
			var c3:Number = coefs[3]/c4;
			var c2:Number = coefs[2]/c4;
			var c1:Number = coefs[1]/c4;
			var c0:Number = coefs[0]/c4;
			var resolveRoots:Vector.<Number> = new Polynomial(  1, -c2, c3*c1-4*c0, -c3*c3*c0+4*c2*c0-c1*c1).getCubicRoots();
			var y:Number = resolveRoots[0];
			var discrim:Number = c3*c3/4-c2+y;
			if (Math.abs(discrim)<=TOLERANCE) {
				discrim = 0;
			}
			if (discrim>0) {
				var e:Number = Math.sqrt(discrim);
				var t1:Number = 3*c3*c3/4-e*e-2*c2;
				t2 = (4*c3*c2-8*c1-c3*c3*c3)/(4*e);
				var plus:Number = t1+t2;
				var minus:Number = t1-t2;
				if (Math.abs(plus)<=TOLERANCE) {
					plus = 0;
				}
				if (Math.abs(minus)<=TOLERANCE) {
					minus = 0;
				}
				if (plus>=0) {
					f = Math.sqrt(plus);
					results.push(-c3/4+(e+f)/2);
					results.push(-c3/4+(e-f)/2);
				}
				if (minus>=0) {
					f = Math.sqrt(minus);
					results.push(-c3/4+(f-e)/2);
					results.push(-c3/4-(f+e)/2);
				}
			} else if (discrim<0) {
				//????
				trace("ERROR IN getQuarticRoots - discrim: "+discrim)
			} else {
				t2 = y*y-4*c0;
				if (t2>=-TOLERANCE) {
					if (t2<0) {
						t2 = 0;
					}
					t2 = 2*Math.sqrt(t2);
					t1 = 3*c3*c3/4-2*c2;
					if (t1+t2>=TOLERANCE) 
					{
						d = Math.sqrt(t1+t2);
						results.push(-c3/4+d/2);
						results.push(-c3/4-d/2);
					}
					if (t1-t2>=TOLERANCE) 
					{
							d = Math.sqrt(t1-t2);
						results.push(-c3/4+d/2);
						results.push(-c3/4-d/2);
					}
				}
			}
		}
		return results;
	};
	
	}
}