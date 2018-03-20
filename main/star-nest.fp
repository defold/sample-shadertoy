// Star Nest by Pablo Román Andrioli

// This content is under the MIT License.

// these constants control the star effect.
// play with them to get different results.
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

// texture coordinates that are set in the vertex shader
varying mediump vec2 var_texcoord0;

// time uniform that is altered by script
uniform lowp vec4 time;

void main()
{
	// define static resolution for the rendering. With a rectangular model of size 1280⨉720
	// we instead set res = vec2(1.78, 1.0); and multiply the uv coordinates with that to get
	// the correct aspect ratio.
	vec2 res = vec2(1.78, 1.0);
	vec2 uv = var_texcoord0.xy * res.xy - 0.5;
	vec3 dir = vec3(uv * zoom, 1.0);

	// read the x component of the time uniform and use it to calculate a time value that
	// is used to animate the star effect.
	// the original shader adds 0.25 to time to start at a nice place so we do that too.
	float time = time.x * speed + 0.25;

	float a1=0.5;
	float a2=0.8;
	mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
	mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
	dir.xz*=rot1;
	dir.xy*=rot2;
	vec3 from = vec3(1.0, 0.5, 0.5);
	from += vec3(time * 2.0, time, -2.0);
	from.xz *= rot1;
	from.xy *= rot2;
	
	//volumetric rendering
	float s = 0.1, fade = 1.0;
	vec3 v = vec3(0.0);
	for(int r = 0; r < volsteps; r++) {
		vec3 p = from + s * dir * 0.5;
		// tiling fold
		p = abs(vec3(tile) - mod(p, vec3(tile * 2.0)));
		float pa, a = pa = 0.0;
		for (int i=0; i < iterations; i++) { 
			// the magic formula
			p = abs(p) / dot(p, p) - formuparam;
			// absolute sum of average change
			a += abs(length(p) - pa);
			pa = length(p);
		}
		//dark matter
		float dm = max(0.0, darkmatter - a * a * 0.001);
		a *= a * a;
		// dark matter, don't render near
		if(r > 6) fade *= 1.0 - dm;
		v += fade;
		// coloring based on distance
		v += vec3(s, s * s, s * s * s * s) * a * brightness * fade;
		fade *= distfading; 
		s += stepsize;
	}
	//color adjust
	v = mix(vec3(length(v)), v, saturation);
	gl_FragColor = vec4(v * 0.01, 1.0);
}