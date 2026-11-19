--!strict
-- NÃO EXECUTADO. Executor mínimo de testes para os módulos de LÓGICA PURA.
-- Funciona igual no Studio (Studio.luau) e no Lune (rodar-lune.luau): quem chama entrega os módulos (M) e as specs.
-- Cada spec é: return function(T, M) T.caso("nome", function() ... end) end

export type T = {
	caso: (nome: string, fn: () -> ()) -> (),
	igual: (obtido: any, esperado: any, msg: string?) -> (),
	perto: (obtido: number, esperado: number, tol: number?, msg: string?) -> (),
	verdade: (v: any, msg: string?) -> (),
	falso: (v: any, msg: string?) -> (),
}

local function Rodar(M: { [string]: any }, specs: { { nome: string, fn: (T, any) -> () } }): (number, number)
	local passou, falhou = 0, 0
	local atual = ""

	local T = {} :: T
	function T.igual(obtido, esperado, msg)
		if obtido ~= esperado then
			error(string.format("%s: esperado %s, obtido %s", msg or "igual", tostring(esperado), tostring(obtido)), 2)
		end
	end
	function T.perto(obtido, esperado, tol, msg)
		if math.abs(obtido - esperado) > (tol or 1e-6) then
			error(string.format("%s: esperado ~%s, obtido %s", msg or "perto", tostring(esperado), tostring(obtido)), 2)
		end
	end
	function T.verdade(v, msg)
		if not v then
			error((msg or "esperado verdadeiro"), 2)
		end
	end
	function T.falso(v, msg)
		if v then
			error((msg or "esperado falso"), 2)
		end
	end
	function T.caso(nome, fn)
		local ok, err = pcall(fn)
		if ok then
			passou += 1
		else
			falhou += 1
			print(string.format("  FALHOU  %s › %s\n          %s", atual, nome, tostring(err)))
		end
	end

	for _, s in specs do
		atual = s.nome
		print("• " .. s.nome)
		s.fn(T, M)
	end
	print(string.format("\nResultado: %d passaram, %d falharam", passou, falhou))
	return passou, falhou
end

return Rodar
