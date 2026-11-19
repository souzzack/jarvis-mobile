--!strict
-- NÃO EXECUTADO. Trava de sessão do perfil — LÓGICA PURA. Usada DENTRO de DataStore:UpdateAsync (que é atômico
-- por chave): o valor salvo é { perfil = …, trava = { servidor = JobId, ate = os.time() + duração } }.
-- Impede dois servidores de escreverem o mesmo perfil (a causa clássica de duplicação de itens).
-- Cada função recebe o valor atual e devolve (novoValor | nil para não escrever, ok, motivo).

export type Registro = { perfil: any?, trava: { servidor: string, ate: number }? }

local T = {}

local function travadoPorOutro(r: Registro?, servidor: string, agora: number): boolean
	return r ~= nil and r.trava ~= nil and r.trava.servidor ~= servidor and r.trava.ate > agora
end

-- Carregar: pega a trava (ou renova a própria). Se outro servidor ainda segura, não escreve.
function T.adquirir(atual: any, servidor: string, agora: number, duracao: number): (Registro?, boolean, string)
	local r: Registro = if type(atual) == "table" then atual else {}
	if travadoPorOutro(r, servidor, agora) then
		return nil, false, "travado"
	end
	r.trava = { servidor = servidor, ate = agora + duracao }
	return r, true, "ok"
end

-- Salvar: só quem segura a trava escreve. Se a trava foi tomada (expirou e outro pegou), NÃO escreve.
function T.salvar(atual: any, perfil: any, servidor: string, agora: number, duracao: number, liberar: boolean): (Registro?, boolean, string)
	local r: Registro = if type(atual) == "table" then atual else {}
	-- sem trava, ou trava de outro servidor (a nossa expirou e ele assumiu): não escreve por cima
	if r.trava == nil or r.trava.servidor ~= servidor then
		return nil, false, "travaPerdida"
	end
	r.perfil = perfil
	r.trava = if liberar then nil else { servidor = servidor, ate = agora + duracao }
	return r, true, if liberar then "liberado" else "salvo"
end

return T
