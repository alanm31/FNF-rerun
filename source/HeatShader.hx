package;

import flixel.system.FlxAssets.FlxShader;

class HeatShader extends FlxShader {
	@:isVar
	public var pixelSizeX(get, set):Float = 1;
	@:isVar
	public var pixelSizeY(get, set):Float = 1;
	@:isVar
	public var pixelSize(get, set):Float = 1;

	function get_pixelSizeX()
	{
		return pSize.value[0];
	}

	function set_pixelSizeX(val:Float)
	{
		return pSize.value[0] = val;
	}

	function get_pixelSizeY()
	{
		return pSize.value[1];
	}

	function set_pixelSizeY(val:Float)
	{
		return pSize.value[1] = val;
	}

	function get_pixelSize()
	{
		return (pSize.value[0] + pSize.value[1]) / 2;
	}

	function set_pixelSize(val:Float)
	{
		pSize.value = [val, val];
		return val;
	}
    
    @:glFragmentSource('
    #pragma header
    uniform float iTime;
    uniform vec2 pSize;
    // Simplex 2D noise
    //
    vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

    float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
            -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
        dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
    }
    float snoise_octaves(vec2 uv, int octaves, float alpha, float beta, vec2 gamma, float delta) {
        vec2 pos = uv;
        float t = 1.0;
        float s = 1.0;
        vec2 q = gamma;
        float r = 0.0;
        for(int i=0;i<octaves;i++) {
            r += s * snoise(pos + q);
            pos += t * uv;
            t *= beta;
            s *= alpha;
            q *= delta;
        }
        return r;
    }

    void main()
    {
        // Normalized pixel coordinates (from 0 to 1)
        vec2 uv = openfl_TextureCoordv;
        
        float dx = 0.0033*snoise_octaves(uv*2.0+iTime*vec2(0.00323,0.00345),9,0.85,-3.0,iTime*vec2(-0.0323,-0.345),1.203);
        float dy = 0.0023*snoise_octaves(uv*2.0+3.0+iTime*vec2(-0.00323,0.00345),9,0.85,-3.0,iTime*vec2(-0.0323,-0.345),1.203);
            
        vec2 uv1 = uv + vec2(dx,dy);
        vec2 size = openfl_TextureSize.xy / pSize;
        vec4 col = flixel_texture2D(bitmap, floor(uv1 * size) / size);
        
        // Output to screen
        gl_FragColor = col;
    }
    ')

    public function new() {
        super();
        iTime.value = [0];
        pSize.value = [1, 1];
    }

    public function update(elapsed:Float){
        iTime.value[0] += elapsed;
    }
}