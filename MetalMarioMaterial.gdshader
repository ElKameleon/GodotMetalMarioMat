shader_type spatial;
render_mode unshaded;

uniform sampler2D matcap_texture : source_color; // sRGB handled by Godot
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;
uniform float desaturation : hint_range(0.0, 1.0) = 0.0; // Desaturates input image for nicer looking tints
uniform float matcap_scale : hint_range(0.0, 1.0) = 1.0; // Used for matcaps that don't go all the way to the edge

void fragment() {
    vec3 V = normalize(-VIEW);
    vec3 N = normalize(NORMAL);

    // Construct tangent space basis (camera-aligned)
    vec3 tangent = normalize(cross(vec3(0.0, 1.0, 0.0), V));
    vec3 bitangent = cross(V, tangent);

    // Project normal into camera space
    float x = dot(N, tangent);
    float y = dot(N, bitangent);

    // Apply matcap scaling and UV centering
    vec2 uv = vec2(-x, -y) * 0.5 * matcap_scale + 0.5;
    uv = clamp(uv, 0.001, 0.999); // Prevent edge oversampling

    // Sample the matcap
    vec3 color = texture(matcap_texture, uv).rgb;

    // Desaturate
    float luma = dot(color, vec3(0.3, 0.59, 0.11));
    vec3 desat = mix(color, vec3(luma), desaturation);

    // Tint
    vec3 tinted = mix(desat, desat * tint_color, tint_amount);

    ALBEDO = tinted;
}
