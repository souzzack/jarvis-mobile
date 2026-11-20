--!strict
-- Roda os testes de lógica automaticamente quando você dá Play no Studio (sem precisar da barra de comandos).
-- O resultado aparece na janela Saída (Output). Desligue em ConfigServidor.rodarTestesAoIniciar.
-- Só roda no Studio: num servidor publicado, nunca.

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ConfigServidor = require(script.Parent.ConfigServidor)

if not RunService:IsStudio() or not ConfigServidor.rodarTestesAoIniciar then
	return
end

local pasta = ServerStorage:WaitForChild("GuardioesTestes", 10)
if not pasta then
	warn("[Guardioes] testes: pasta ServerStorage.GuardioesTestes não encontrada (o Rojo está conectado?)")
	return
end
print("[Guardioes] ===== TESTES DE LÓGICA: início =====")
local ok, erro = pcall(function()
	return require(pasta:WaitForChild("Studio") :: ModuleScript)()
end)
if not ok then
	warn("[Guardioes] testes: falhou ao rodar: " .. tostring(erro))
end
print("[Guardioes] ===== TESTES DE LÓGICA: fim =====")
