# teste-conectividade.ps1
# Testa a conectividade da rede (ping, DNS e porta TCP) e gera um relatório CSV.

# Descobre automaticamente o gateway e o servidor DNS da máquina
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
            Sort-Object RouteMetric | Select-Object -First 1).NextHop
$servidorDns = (Get-DnsClientServerAddress -AddressFamily IPv4 |
                Where-Object { $_.ServerAddresses } |
                Select-Object -First 1).ServerAddresses[0]

function Testar-Ping($nome, $alvo) {
    $ok = Test-Connection -ComputerName $alvo -Count 2 -Quiet -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Horario = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Teste   = $nome
        Alvo    = $alvo
        Status  = if ($ok) { "OK" } else { "FALHA" }
    }
}

function Testar-DNS($nome) {
    try   { $null = Resolve-DnsName $nome -ErrorAction Stop; $status = "OK" }
    catch { $status = "FALHA" }
    [PSCustomObject]@{
        Horario = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Teste   = "Resolucao DNS"
        Alvo    = $nome
        Status  = $status
    }
}

function Testar-Porta($alvo, $porta) {
    $ok = Test-NetConnection -ComputerName $alvo -Port $porta `
          -InformationLevel Quiet -WarningAction SilentlyContinue
    [PSCustomObject]@{
        Horario = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Teste   = "TCP porta $porta"
        Alvo    = $alvo
        Status  = if ($ok) { "OK" } else { "FALHA" }
    }
}

Write-Host "Executando testes de conectividade..." -ForegroundColor Cyan

$resultados = @(
    Testar-Ping "Ping gateway"         $gateway
    Testar-Ping "Ping servidor DNS"    $servidorDns
    Testar-Ping "Ping Internet (IP)"   "8.8.8.8"
    Testar-DNS  "github.com"
    Testar-Porta "github.com" 443
)

$resultados | Format-Table -AutoSize

$arquivo = Join-Path $PSScriptRoot ("relatorio-conectividade-{0}.csv" -f (Get-Date -Format "yyyyMMdd-HHmm"))
$resultados | Export-Csv -Path $arquivo -NoTypeInformation -Encoding UTF8
Write-Host "Relatorio salvo em: $arquivo" -ForegroundColor Green