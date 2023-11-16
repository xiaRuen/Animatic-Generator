#version 100

uniform float x;

attribute vec2 aOrigin;
attribute vec2 aTexCoord;

attribute vec2 aPos;
attribute vec2 aVel;
attribute vec2 aAcc;

attribute vec3 aRad;
attribute vec3 aRadVel;
attribute vec3 aRadAcc;

varying vec2 vPos;
varying vec2 vTexCoord;

void main() {
    // s = ut + ½ at2  →  displacement = vel * x + 0.5 * acc * x * x
    vec2 displacement = aVel * x + 0.5 * aAcc * x * x;

    // rotation around the origin
    // first calculate the rotational matrixs
    vec3 angularDisplacement = aRadVel * x + 0.5 * aRadAcc * x * x;
    vec3 r = aRad + angularDisplacement;
    // x' = x cosβ - y sinβ
    // y' = x cosβ + x sinβ
    mat4 rotX = mat4(
        1.0,        0.0,        0.0,        0.0, // first column
        0.0,        cos(r.x),   sin(r.x),   0.0, // second column
        0.0,        -sin(r.x),  cos(r.x),   0.0, // third column
        0.0,        0.0,        0.0,        1.0 // fourth column
    ); 

    mat4 rotY = mat4(
        cos(r.y),   0.0,        -sin(r.y),  0.0,
        0.0,        1.0,        0.0,        0.0,
        sin(r.y),   0,          cos(r.y),   0.0,
        0.0,        0.0,        0.0,        1.0
    ); 

    mat4 rotZ = mat4(
        cos(r.z),   sin(r.z),   0.0,        0.0,
        -sin(r.z),  cos(r.z),   0.0,        0.0,
        0.0,        0.0,        1.0,        0.0,
        0.0,        0.0,        0.0,        1.0
    );

    mat4 translations = mat4(
        1.0,        0.0,        0.0,        0.0,
        0.0,        1.0,        0.0,        0.0,
        0.0,        0.0,        1.0,        0.0,
        aOrigin.x,  aOrigin.y,  0.0,        1.0
    );

    vec4 posAfterRotation = translations * rotZ * rotY * rotX * -translations * vec4(aPos, 0, 1);

    // gl_Position = vec4(posAfterRotation.xy, 0, 1) + vec4(displacement, 0, 1);
    gl_Position = vec4(posAfterRotation.xy + displacement, 0, 1);

    vPos = aPos;
    vTexCoord = aTexCoord;

}
