attribute vec4 tangent;
uniform float uTime;
uniform float uTimeFrequency;
uniform float uStrength;
uniform float uPositionFrequency;
uniform float uWrapPositionFrequency;
uniform float uWrapTimeFrequency;
uniform float uWrapStrength;
#include ../includes/simplexNoise4d.glsl

varying float vWobble;

float getWobble(vec3 position){
    vec3 warpedPosition = position;
    warpedPosition.x += simplexNoise4d(vec4(
        //positionxyz
        position * uWrapPositionFrequency,
        uTime * uWrapTimeFrequency
    )) * uWrapStrength;


    return simplexNoise4d(vec4(
        //positionxyz
        warpedPosition * uPositionFrequency, 
        //w
        uTime * uTimeFrequency
    )) * uStrength;
}

void main()
{
    vec3 biTangent = cross(normal, tangent.xyz);
    //neighbours positions
    float shift = 0.01;
    vec3 positionA = csm_Position + tangent.xyz * shift;
    vec3 positionB = csm_Position + biTangent * shift;
    //wobble
    float wobble = getWobble(csm_Position);
    csm_Position += wobble * normal;
    positionA += getWobble(positionA) * normal;
    positionB += getWobble(positionB) * normal;
    //calculate normals
    vec3 toA = normalize(positionA - csm_Position);
    vec3 toB = normalize(positionB - csm_Position);
    csm_Normal = cross(toA, toB);
    vWobble = wobble / uStrength;
}