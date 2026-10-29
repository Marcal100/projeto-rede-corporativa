\# Rede Corporativa com 3 Localidades



Projeto prático de redes que reúne o conteúdo do curso de redes da Cisco: uma empresa com \*\*matriz e duas filiais\*\*, segmentada em VLANs, com roteamento dinâmico, serviços de rede, saída para a Internet e camadas básicas de segurança. A rede foi simulada no \*\*Cisco Packet Tracer\*\*, os protocolos foram analisados na prática com o \*\*Wireshark\*\* e a conectividade foi automatizada com \*\*PowerShell\*\*.



\## Ferramentas



\- Cisco Packet Tracer (simulação da rede)

\- Wireshark (análise de tráfego real)

\- Windows PowerShell (automação de testes)



\## Topologia



!\[Topologia da rede](imagens/01-topologia.png)



\## O que foi implementado



\- \*\*VLANs\*\* na matriz (TI, Financeiro, RH, Visitantes e Servidores) com roteamento entre VLANs (\*router-on-a-stick\*)

\- \*\*OSPF\*\* (área 0) conectando matriz e filiais

\- \*\*DHCP centralizado\*\* no roteador da matriz, atendendo também as filiais via `ip helper-address`

\- \*\*DNS\*\* com servidor dedicado na VLAN de Servidores

\- \*\*NAT/PAT\*\* para saída à Internet simulada (ISP), com rota padrão propagada às filiais pelo OSPF

\- \*\*ACL\*\* isolando a rede de Visitantes: acesso apenas à Internet

\- \*\*SSH (v2)\*\* nos equipamentos, com Telnet desativado

\- \*\*Port security\*\* nas portas de usuário e desligamento das portas não utilizadas



\## Plano de endereçamento



| Local | VLAN | Nome | Rede | Gateway |

|---|---|---|---|---|

| Matriz | 10 | TI | 192.168.10.0/24 | 192.168.10.1 |

| Matriz | 20 | Financeiro | 192.168.20.0/24 | 192.168.20.1 |

| Matriz | 30 | RH | 192.168.30.0/24 | 192.168.30.1 |

| Matriz | 40 | Visitantes | 192.168.40.0/24 | 192.168.40.1 |

| Matriz | 50 | Servidores | 192.168.50.0/24 | 192.168.50.1 |

| Filial 1 | - | LAN | 192.168.101.0/24 | 192.168.101.1 |

| Filial 2 | - | LAN | 192.168.102.0/24 | 192.168.102.1 |

| Link Matriz - Filial 1 | - | WAN | 10.0.0.0/30 | .1 Matriz / .2 Filial 1 |

| Link Matriz - Filial 2 | - | WAN | 10.0.0.4/30 | .5 Matriz / .6 Filial 2 |

| Matriz - ISP | 99 | Internet | 200.0.0.0/30 | .2 Matriz / .1 ISP |

| ISP - Servidor externo | - | Internet simulada | 203.0.113.0/24 | 203.0.113.1 |



\## Evidências



\### NAT/PAT em funcionamento

O IP privado de um PC da filial 1 é traduzido para o IP do link com o ISP.



!\[Tabela de NAT](imagens/02-nat-translations.png)



\### ACL de isolamento dos Visitantes

Os contadores mostram o tráfego para a rede interna sendo bloqueado e o tráfego para a Internet sendo liberado.



!\[ACL](imagens/03-acl.png)



\### Handshake TCP no Wireshark

Captura real do tráfego do computador: `SYN`, `SYN-ACK` e `ACK` na abertura de uma conexão HTTPS (porta 443).



!\[Handshake TCP](imagens/05-wireshark-tcp.png)



\## Automação com PowerShell



O script \[`powershell/teste-conectividade.ps1`](powershell/teste-conectividade.ps1) testa a conectividade da máquina (ping ao gateway, ao servidor DNS e à Internet, resolução de DNS e porta TCP 443) e gera um relatório em CSV.



!\[Resultado do script](imagens/04-powershell-conectividade.png)



Para executar:



```powershell

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\\powershell\\teste-conectividade.ps1

```



\## Como abrir a simulação



1\. Instale o Cisco Packet Tracer

2\. Abra o arquivo \[`packet-tracer/projeto-rede-corporativa.pkt`](packet-tracer/projeto-rede-corporativa.pkt)



\## Estrutura do repositório



```

├── README.md

├── imagens/

├── packet-tracer/

│   └── projeto-rede-corporativa.pkt

└── powershell/

&#x20;   └── teste-conectividade.ps1

```



\## Observações



\- Projeto de laboratório: os endereços públicos usados (200.0.0.0/30 e 203.0.113.0/24) são fictícios.

\- As configurações dos equipamentos não estão incluídas no repositório, mas podem ser consultadas abrindo o arquivo `.pkt`.

