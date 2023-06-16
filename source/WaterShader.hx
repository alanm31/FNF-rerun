package;

import flixel.system.FlxAssets.FlxShader;

class WaterShader extends FlxShader {
	@:isVar
	public var evil(get, set):Bool = false;
	@:isVar
	public var frame(get, set):Int = 0;

	function get_evil()
		return isEvil.value[0];

	function set_evil(val:Bool)
		return isEvil.value[0] = val;

	function get_frame()
		return cycle.value[0];

	function set_frame(val:Int)
		return cycle.value[0] = val;

    @:glFragmentSource('
        #pragma header
        uniform bool isEvil;
        uniform int cycle;
        vec3 replacingColours[4] = vec3[4](
            vec3(119.0, 17.0, 119.0),
            vec3(153.0, 51.0, 153.0),
            vec3(187.0, 85.0, 187.0),
            vec3(221.0, 119.0, 221.0)
        );


        //uniform vec3 colours[4];

		void main()
		{
            vec2 uv = openfl_TextureCoordv;
            vec4 col = flixel_texture2D(bitmap, uv);
            vec3 colRgb = col.rgb;
            vec3 colours[4];
            if(isEvil){
                 colours = vec3[4](
                    vec3(170.0, 0.0, 0.0),
                    vec3(238.0, 0.0, 0.0),
                    vec3(238.0, 68.0, 34.0),
                    vec3(238.0, 136.0, 68.0) 
                );
            }else{
                colours = vec3[4](
                    vec3(108.0, 144.0, 180.0),
                    vec3(108.0, 144.0, 252.0),
                    vec3(144.0, 180.0, 252.0),
                    vec3(180.0, 216.0, 252.0) 
                );
            }

            for(int i=0; i<4; ++i)
            {
                vec3 colour = replacingColours[i];
                if(colRgb*255.0 == colour){
                    gl_FragColor = vec4(colours[int(abs(float(mod(i-4-cycle,4.0))))]/255.0,col.a); // thanks glsl for not letting me abs(int), if only i could version 130 lol.. actually maybe i can???
                    return;
                }
            }

            gl_FragColor = col;
        }
    ')
	public function new()
	{
		super();
		cycle.value = [0];
		isEvil.value = [false];
	}
}