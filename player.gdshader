shader_type canvas_item;

// Captura a imagem do jogo por trás do ColorRect
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Controla quantas cores o jogo vai renderizar. 
// O PS1 tinha uma paleta bem limitada. 32.0 a 64.0 é um bom número.
uniform float color_depth : hint_range(1.0, 256.0) = 32.0;

void fragment() {
	// Pega o pixel atual da tela
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	// Arredonda a cor para o valor mais próximo baseado na nossa profundidade
	color.rgb = floor(color.rgb * color_depth) / color_depth;
	
	// Aplica a cor modificada na tela
	COLOR = color;
}