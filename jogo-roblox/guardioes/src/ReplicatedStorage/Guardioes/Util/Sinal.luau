--!strict
-- NÃO EXECUTADO. Sinal mínimo para os sistemas conversarem sem depender um do outro (sem BindableEvent).

export type Conexao = { desconectar: () -> () }
export type Sinal<T...> = {
	conectar: (fn: (T...) -> ()) -> Conexao,
	disparar: (T...) -> (),
}

local Sinal = {}

function Sinal.novo<T...>(): Sinal<T...>
	local ouvintes: { [number]: (T...) -> () } = {}
	local proximo = 0
	local s = {} :: any
	function s.conectar(fn: (T...) -> ()): Conexao
		proximo += 1
		local id = proximo
		ouvintes[id] = fn
		return {
			desconectar = function()
				ouvintes[id] = nil
			end,
		}
	end
	function s.disparar(...: T...)
		-- copia antes de chamar: um ouvinte pode se desconectar durante o disparo
		local copia = {}
		for id, fn in ouvintes do
			copia[id] = fn
		end
		for _, fn in copia do
			fn(...)
		end
	end
	return s :: Sinal<T...>
end

return Sinal
