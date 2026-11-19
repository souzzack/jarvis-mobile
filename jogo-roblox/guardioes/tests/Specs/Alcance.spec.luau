-- NÃO EXECUTADO. Testes geométricos do acerto (plano XZ).

return function(T, M)
	local A = M.Alcance

	T.caso("na frente e ao alcance acerta; ao lado de um arco estreito não", function()
		T.verdade(A.noArco(0, 0, 1, 0, 5, 0, 7, 90, 0))
		T.falso(A.noArco(0, 0, 1, 0, 0, 5, 7, 90, 0))
	end)

	T.caso("alcance considera o raio do corpo do alvo", function()
		T.falso(A.noArco(0, 0, 1, 0, 9, 0, 7, 90, 1))
		T.verdade(A.noArco(0, 0, 1, 0, 7.5, 0, 7, 90, 1))
	end)

	T.caso("atrás não acerta; arco de 360 acerta", function()
		T.falso(A.noArco(0, 0, 1, 0, -3, 0, 7, 110, 0))
		T.verdade(A.noArco(0, 0, 1, 0, -3, 0, 7, 360, 0))
	end)

	T.caso("largura do alvo amplia o ângulo aceito", function()
		-- alvo a 45° e ~7,07 studs; arco 60 (meia-abertura 30°)
		T.falso(A.noArco(0, 0, 1, 0, 5, 5, 10, 60, 0))
		T.verdade(A.noArco(0, 0, 1, 0, 5, 5, 10, 60, 3))
	end)

	T.caso("frontal (defesa de 120°)", function()
		T.verdade(A.frontal(0, 0, 0, 1, 0, 5, 120))
		T.falso(A.frontal(0, 0, 0, 1, 0, -5, 120))
		T.falso(A.frontal(0, 0, 0, 1, 5, 1, 120))
		T.verdade(A.frontal(0, 0, 0, 1, 0, 0, 120), "colado conta como frente")
	end)

	T.caso("distância no plano", function()
		T.perto(A.distancia(0, 0, 3, 4), 5)
	end)
end
