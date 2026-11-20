# Guardiões do Multiverso — prepara o teste no Roblox Studio (Windows, PowerShell).
# O que faz, nesta ordem:
#   1. baixa (ou atualiza) o código do branch de desenvolvimento numa pasta sua;
#   2. baixa o Rojo 7.4.4 (sincronizador oficial) para dentro dessa pasta — não instala nada no sistema;
#   3. instala o plugin do Rojo no Studio (comando oficial "rojo plugin install");
#   4. inicia o "rojo serve" (deixe esta janela aberta enquanto testa).
# Não mexe em nenhum place: quem conecta é você, numa CÓPIA do jogo, pelo botão Connect do plugin.
# Uso:  powershell -ExecutionPolicy Bypass -File preparar-studio.ps1
$ErrorActionPreference = "Stop"
$Repo   = "https://github.com/souzzack/jarvis-mobile.git"
$Branch = "claude/intelligent-cerf-lfd2d7"
$Base   = Join-Path $HOME "GuardioesTeste"
$Versao = "7.4.4"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Falta o Git. Instale em https://git-scm.com/download/win e rode de novo." -ForegroundColor Red
    exit 1
}
if (Test-Path (Join-Path $Base ".git")) {
    Write-Host "Atualizando o código em $Base ..."
    git -C $Base fetch origin $Branch
    git -C $Base checkout $Branch
    git -C $Base pull --ff-only origin $Branch
} else {
    Write-Host "Baixando o código para $Base ..."
    git clone --branch $Branch --single-branch $Repo $Base
}
$Projeto = Join-Path $Base "jogo-roblox\guardioes"
$Ferr = Join-Path $Projeto "ferramentas\bin"
$Rojo = Join-Path $Ferr "rojo.exe"
if (-not (Test-Path $Rojo)) {
    New-Item -ItemType Directory -Force -Path $Ferr | Out-Null
    $Zip = Join-Path $Ferr "rojo.zip"
    $Url = "https://github.com/rojo-rbx/rojo/releases/download/v$Versao/rojo-$Versao-windows-x86_64.zip"
    Write-Host "Baixando o Rojo $Versao ..."
    Invoke-WebRequest -Uri $Url -OutFile $Zip
    Expand-Archive -Path $Zip -DestinationPath $Ferr -Force
    Remove-Item $Zip
}
Write-Host "Instalando o plugin do Rojo no Studio (feche e abra o Studio depois, se ele já estiver aberto)..."
& $Rojo plugin install
Write-Host ""
Write-Host "PRONTO. Agora, no Studio:" -ForegroundColor Green
Write-Host "  1. Abra uma CÓPIA do seu place (Arquivo > Salvar no arquivo como...)."
Write-Host "  2. Aba Plugins > Rojo > Connect."
Write-Host "  3. Barra de comandos:  require(game.ServerStorage.GuardioesTestes.Studio)()"
Write-Host "  4. Play (F5) e copie as linhas vermelhas do Output."
Write-Host ""
Write-Host "Sincronizando (deixe esta janela aberta; Ctrl+C para parar)..."
Set-Location $Projeto
& $Rojo serve
