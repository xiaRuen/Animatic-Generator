#version 100

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mediump sampler2D textureSampler;

varying vec2 vPos;
varying vec2 vTexCoord;

void main(){
    // gl_FragColor = vec4(0,0,0.5 + 0.5 * vPos.x,1);
    gl_FragColor = texture2D(textureSampler, vTexCoord);
    
}
