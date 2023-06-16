package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
import flixel.math.FlxPoint;

class PiracyEffect
{
  public var shader:PiracyShader = new PiracyShader();
  public function new(?usesStaticShader:Bool = true){
    shader.iTime.value = [0];
    shader.usesStatic.value = [usesStaticShader];
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
    var noise = Assets.getBitmapData('assets/images/shot_1.png');
    shader.noiseTex.input = noise;
  }

  public function update(elapsed:Float){
    shader.iTime.value[0] += elapsed;
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
  }
}

class PiracyShader extends FlxShader
{
  @:glFragmentSource('
    #pragma header

    uniform vec3 iResolution;
    uniform float iTime;
    uniform sampler2D noiseTex;
    uniform bool usesStatic;

    vec4 getVideo(vec2 uv)
      {
      	vec2 look = uv;
      	vec4 video = flixel_texture2D(bitmap,look);
      	return video;
      }

    float scanline(vec2 uv) {
        return sin(iResolution.y * uv.y * 0.7 - iTime * 10.0);
    }
    
    float slowscan(vec2 uv) {
        return sin(iResolution.y * uv.y * 0.02 + iTime * 6.0);
    }
    
    vec2 colorShift(vec2 uv) {
        return vec2(
            uv.x,
            uv.y + sin(iTime)*0.02
        );
    }
    
    float random(vec2 uv)
    {
     	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }
    float noise(vec2 uv)
    {
     	vec2 i = floor(uv);
        vec2 f = fract(uv);
        float a = random(i);
        float b = random(i + vec2(1.,0.));
    	float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));
        vec2 u = smoothstep(0., 1., f);
        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
    }
    
    vec2 crt(vec2 coord, float bend)
    {
        coord = (coord - 0.5) * 2.0;
        coord *= 0.5;	
        coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
        coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);
        coord  = (coord / 1.0) + 0.5;
    
        return coord;
    }
    
    vec2 colorshift(vec2 uv, float amount, float rand) {
        
        return vec2(
            uv.x,
            uv.y + amount * rand // * sin(uv.y * iResolution.y * 0.12 + iTime)
        );
    }
    
    vec2 scandistort(vec2 uv) {
    	float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
    	float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0);
    	float amount = scan1 * scan2 * uv.x;
      uv = uv * 2.0 - 1.0;
      uv *= 0.9;
      uv = (uv + 1.0) * 0.5;
    	uv.x -= 0.02 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.2);

    	return uv;
         
    }
    
    float vignette(vec2 uv) {
        uv = (uv - 0.5) * 0.98;
        return clamp(pow(cos(uv.x * 3.1415), 1.2) * pow(cos(uv.y * 3.1415), 1.2) * 50.0, 0.0, 1.0);
    }
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        vec2 sd_uv = scandistort(uv);
        vec2 crt_uv = crt(sd_uv, 2.0);
        uv = crt_uv;
        vec4 video = getVideo(uv);
        float x =  0.;
        vec4 color;
        //float rand_r = sin(iTime * 3.0 + sin(iTime)) * sin(iTime * 0.2);
        //float rand_g = clamp(sin(iTime * 1.52 * uv.y + sin(iTime)) * sin(iTime* 1.2), 0.0, 1.0);
        //vec4 rand = texture(noiseTex, vec2(iTime * 0.01, iTime * 0.02));
        video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
        video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
        video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
        video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
        video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
        video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;
        vec4 scanline_color = vec4(scanline(crt_uv));
        vec4 slowscan_color = vec4(slowscan(crt_uv));
        if (usesStatic)
          {
            gl_FragColor = mix(video,vec4(noise(uv * 250.)),.05);
          }
        else
          {
            gl_FragColor = video;
          }
    
        //fragColor = vec4(vignette(uv));
        //vec2 scan_dist = scandistort(uv);
        //fragColor = vec4(scan_dist.x, scan_dist.y,0.0, 1.0);
    }
  ')
  public function new()
  {
    super();
  }
}




class NtscShader extends FlxShader {
	@:glFragmentSource('
		#pragma header

		#pragma format R8G8B8A8_SRGB

		#define NTSC_CRT_GAMMA 2.5
		#define NTSC_MONITOR_GAMMA 2.0

		#define TWO_PHASE
		#define COMPOSITE
		//#define THREE_PHASE
		// #define SVIDEO

		// begin params
		#define PI 3.14159265

		#if defined(TWO_PHASE)
			#define CHROMA_MOD_FREQ (4.0 * PI / 15.0)
		#elif defined(THREE_PHASE)
			#define CHROMA_MOD_FREQ (PI / 3.0)
		#endif

		#if defined(COMPOSITE)
			#define SATURATION 1.0
			#define BRIGHTNESS 1.0
			#define ARTIFACTING 1.0
			#define FRINGING 1.0
		#elif defined(SVIDEO)
			#define SATURATION 1.0
			#define BRIGHTNESS 1.0
			#define ARTIFACTING 0.0
			#define FRINGING 0.0
		#endif
		// end params

		uniform int uFrame;
		uniform float uInterlace;

		// fragment compatibility #defines

		#if defined(COMPOSITE) || defined(SVIDEO)
		mat3 mix_mat = mat3(
			BRIGHTNESS, FRINGING, FRINGING,
			ARTIFACTING, 2.0 * SATURATION, 0.0,
			ARTIFACTING, 0.0, 2.0 * SATURATION
		);
		#endif

		// begin ntsc-rgbyuv
		const mat3 yiq2rgb_mat = mat3(
			1.0, 0.956, 1.6210, //og 0.6210 
			1.0, -0.2720, -0.6474,
			1.0, -1.1060, 2.3046); //og 1.7046

		vec3 yiq2rgb(vec3 yiq)
		{
			return yiq * yiq2rgb_mat;
		}

		const mat3 yiq_mat = mat3(
			0.2989, 0.5870, 0.1140,
			0.5959, -0.2744, -0.3216,
			0.2115, -0.5229, 0.3114
		);

		vec3 rgb2yiq(vec3 col)
		{
			return col * yiq_mat;
		}
		// end ntsc-rgbyuv

		#define TAPS 32
		const float luma_filter[TAPS + 1] = float[TAPS + 1](
			-0.000174844,
			-0.000205844,
			-0.000149453,
			-0.000051693,
			0.000000000,
			-0.000066171,
			-0.000245058,
			-0.000432928,
			-0.000472644,
			-0.000252236,
			0.000198929,
			0.000687058,
			0.000944112,
			0.000803467,
			0.000363199,
			0.000013422,
			0.000253402,
			0.001339461,
			0.002932972,
			0.003983485,
			0.003026683,
			-0.001102056,
			-0.008373026,
			-0.016897700,
			-0.022914480,
			-0.021642347,
			-0.008863273,
			0.017271957,
			0.054921920,
			0.098342579,
			0.139044281,
			0.168055832,
			0.178571429);

		const float chroma_filter[TAPS + 1] = float[TAPS + 1](
			0.001384762,
			0.001678312,
			0.002021715,
			0.002420562,
			0.002880460,
			0.003406879,
			0.004004985,
			0.004679445,
			0.005434218,
			0.006272332,
			0.007195654,
			0.008204665,
			0.009298238,
			0.010473450,
			0.011725413,
			0.013047155,
			0.014429548,
			0.015861306,
			0.017329037,
			0.018817382,
			0.020309220,
			0.021785952,
			0.023227857,
			0.024614500,
			0.025925203,
			0.027139546,
			0.028237893,
			0.029201910,
			0.030015081,
			0.030663170,
			0.031134640,
			0.031420995,
			0.031517031);

		// #define fetch_offset(offset, one_x) \\
		// 	pass1(uv - vec2(0.5 / openfl_TextureSize.x, 0.0) + vec2((offset) * (one_x), 0.0)).xyzw

		#define fetch_offset(offset, one_x) \\
			pass1(uv + vec2((offset - 0.5) * one_x, 0.0)).xyzw

		vec4 pass1(vec2 uv)
		{
			vec2 fragCoord = uv * openfl_TextureSize;

			vec4 cola = texture2D(bitmap, uv).rgba;
			vec3 yiq = rgb2yiq(cola.rgb);

			#if defined(TWO_PHASE)
				float chroma_phase = PI * (mod(fragCoord.y, 2.0) + float(uFrame));
			#elif defined(THREE_PHASE)
				float chroma_phase = 0.6667 * PI * (mod(fragCoord.y, 3.0) + float(uFrame));
			#endif

			float mod_phase = chroma_phase + fragCoord.x * CHROMA_MOD_FREQ;

			float i_mod = cos(mod_phase);
			float q_mod = sin(mod_phase);

			if(uInterlace == 1.0) {
				yiq.yz *= vec2(i_mod, q_mod); // Modulate.
				yiq *= mix_mat; // Cross-talk.
				yiq.yz *= vec2(i_mod, q_mod); // Demodulate.
			}
			return vec4(yiq, cola.a);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec2 fragCoord = uv * openfl_TextureSize;

			float one_x = 1.0 / openfl_TextureSize.x;
			vec4 signal = vec4(0.0);

			for (int i = 0; i < TAPS; i++)
			{
				float offset = float(i);

				vec4 sums = fetch_offset(offset - float(TAPS), one_x) +
					fetch_offset(float(TAPS) - offset, one_x);

				signal += sums * vec4(luma_filter[i], chroma_filter[i], chroma_filter[i], 1.0);
			}
			signal += pass1(uv - vec2(0.5 / openfl_TextureSize.x, 0.0)).xyzw *
				vec4(luma_filter[TAPS], chroma_filter[TAPS], chroma_filter[TAPS], 1.0);

			vec3 rgb = yiq2rgb(signal.xyz);
			float alpha = signal.a/(TAPS+1);
			vec4 color = vec4(pow(rgb, vec3(NTSC_CRT_GAMMA / NTSC_MONITOR_GAMMA)), alpha);
			gl_FragColor = color;
		}
		')

	var topPrefix:String = "";

	public function new() {
		topPrefix = "#version 120\n\n";
		__glSourceDirty = true;

		super();

		this.uFrame.value = [0];
		this.uInterlace.value = [1];
	}

	public var interlace(get, set):Bool;

	function get_interlace() {
		return this.uInterlace.value[0] == 1.0;
	}
	function set_interlace(val:Bool) {
		this.uInterlace.value[0] = val ? 1.0 : 0.0;
		return val;
	}

	override function __updateGL() {
		//this.uFrame.value[0]++;
		this.uFrame.value[0] = (this.uFrame.value[0] + 1) % 2;

		super.__updateGL();
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		@:privateAccess if (__context != null && program == null)
		{
			var gl = __context.gl;

			#if (js && html5)
			var prefix = (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
			#else
			var prefix = "#ifdef GL_ES\n"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
					+ "precision highp float;\n"
					+ "#else\n"
					+ "precision mediump float;\n"
					+ "#endif\n" : "precision lowp float;\n")
				+ "#endif\n\n";
			#end

			var vertex = topPrefix + prefix + glVertexSource;
			var fragment = topPrefix + prefix + glFragmentSource;

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				// TODO
				// program.uploadSources (vertex, fragment);
				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{
					if (input.__isUniform)
					{
						input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				for (parameter in __paramBool)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramFloat)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramInt)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
		}
	}
}

class NtscFX extends Effect{

	public var shader:NtscShader;
	public function new(){
		shader = new NtscShader();
	}

}


class Effect {
	public function setValue(shader:FlxShader, variable:String, value:Float){
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}
	
}




class BloomEffect
{
  public var shader:BloomShader = new BloomShader();
  public function new(?usesStaticShader:Bool = true){
    shader.iTime.value = [0];
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
  }

  public function update(elapsed:Float){
    shader.iTime.value[0] += elapsed;
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
  }
}

class BloomShader extends FlxShader
{
  @:glFragmentSource('
  #pragma header
  vec2 uv = openfl_TextureCoordv.xy;
  vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
  uniform vec2 iResolution;
  uniform float iTime;
  #define iChannel0 bitmap
  #define texture flixel_texture2D
  #define fragColor gl_FragColor
  #define mainImage main


  const float blurSize = 2.0/512.0;
	const float intensity = 0.20;
	void mainImage()
	{
	vec4 sum = vec4(0);
	vec2 texcoord = fragCoord.xy/iResolution.xy;
	int j;
	int i;

	// blur in y (vertical)
	// take nine samples, with the distance blurSize between them
	sum += texture(bitmap, vec2(texcoord.x - 4.0*blurSize, texcoord.y)) * 0.05;
	sum += texture(bitmap, vec2(texcoord.x - 3.0*blurSize, texcoord.y)) * 0.09;
	sum += texture(bitmap, vec2(texcoord.x - 2.0*blurSize, texcoord.y)) * 0.12;
	sum += texture(bitmap, vec2(texcoord.x - blurSize, texcoord.y)) * 0.15;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
	sum += texture(bitmap, vec2(texcoord.x + blurSize, texcoord.y)) * 0.15;
	sum += texture(bitmap, vec2(texcoord.x + 2.0*blurSize, texcoord.y)) * 0.12;
	sum += texture(bitmap, vec2(texcoord.x + 3.0*blurSize, texcoord.y)) * 0.09;
	sum += texture(bitmap, vec2(texcoord.x + 4.0*blurSize, texcoord.y)) * 0.05;
	
	// blur in y (vertical)
	// take nine samples, with the distance blurSize between them
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y - 4.0*blurSize)) * 0.05;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y - 3.0*blurSize)) * 0.09;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y - 2.0*blurSize)) * 0.12;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y - blurSize)) * 0.15;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y + blurSize)) * 0.15;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y + 2.0*blurSize)) * 0.12;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y + 3.0*blurSize)) * 0.09;
	sum += texture(bitmap, vec2(texcoord.x, texcoord.y + 4.0*blurSize)) * 0.05;

	//increase blur with intensity!
	fragColor = sum*intensity + texture(bitmap, texcoord); 

	}
  ')
  public function new()
  {
    super();
  }
}
