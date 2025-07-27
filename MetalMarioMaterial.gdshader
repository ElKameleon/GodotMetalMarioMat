shader_type spatial;
render_mode unshaded;

uniform sampler2D matcap_texture;
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0); //Tint color to make other metals like gold/copper
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;
uniform float desaturation : hint_range(0.0, 1.0) = 0.0; //Desaturate matcap image, useful to get some dark contrast
uniform float matcap_scale : hint_range(0.0, 1.0) = 1.0; // Scale for if your matcap material doesn't go all the way to the edge of the image. I use 0.95 for the original metal mario texture
void fragment() {
    // Inverse of the VIEW vector (eye direction, normalized)
    vec3 V = normalize(-VIEW);
    vec3 N = normalize(NORMAL);

    // Create a view-aligned tangent basis (camera-space axes)
    vec3 tangent = normalize(cross(vec3(0.0, 1.0, 0.0), V));
    vec3 bitangent = cross(V, tangent);

    // Convert world normal to view-space by projecting onto the basis
    float x = dot(N, tangent);
    float y = dot(N, bitangent);

    // Apply scale to UV projection
    vec2 uv = vec2(-x, -y) * 0.5 * matcap_scale + 0.5;

    // Clamp to prevent UV overrun
    uv = clamp(uv, 0.001, 0.999);

    // Sample matcap
    vec3 color = texture(matcap_texture, uv).rgb;
    color = pow(color, vec3(2.2)); // Gamma correct from sRGB to linear otherwise the result is blown out

    // Desaturation
    float luma = dot(color, vec3(0.3, 0.59, 0.11));
    vec3 desat = mix(color, vec3(luma), desaturation);

    // Tint
    vec3 tinted = mix(desat, desat * tint_color, tint_amount);

    ALBEDO = tinted;
}
