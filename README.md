<div align="center">

# Linux Server Health Check

### Diagnóstico rápido e seguro de servidores Linux em Shell Script

![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Status](https://img.shields.io/badge/status-funcional-success?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

</div>

---

## Sobre o projeto

O **Linux Server Health Check** é uma ferramenta desenvolvida em Shell Script para realizar uma verificação rápida da saúde de servidores e estações Linux.

O script coleta informações do sistema em modo **somente leitura**, sem alterar configurações, interromper serviços ou executar ações destrutivas.

Foi criado como projeto de estudo e portfólio, aplicando conceitos de:

- Administração Linux
- Monitoramento de infraestrutura
- Shell Script
- Diagnóstico de recursos
- Segurança operacional
- Automação de rotinas

---

## Funcionalidades

O script verifica:

- Sistema operacional
- Versão do kernel
- Arquitetura da máquina
- Tempo de atividade
- Uso de CPU
- Uso de memória
- Utilização do disco principal
- Carga média do sistema
- Interface de rede principal
- Endereço IPv4
- Gateway padrão
- Conectividade externa
- Serviços com falha
- Estado geral do equipamento

---

## Exemplo de execução

```text
LINUX SERVER HEALTH CHECK v1.0.1
Data: 2026-07-19 00:17:25 -03
Modo: somente leitura
------------------------------------------------------------------------

SISTEMA
------------------------------------------------------------------------
Hostname                 servidor-linux                  [INFO]
Sistema operacional      Ubuntu Linux                    [INFO]
Kernel                   Linux Kernel                    [INFO]
Arquitetura              x86_64                          [INFO]
Uptime                   1 hour, 4 minutes               [INFO]

RECURSOS
------------------------------------------------------------------------
Uso de CPU               1%                              [OK]
Uso de memoria           52%                             [OK]
Disco raiz (/)           10%                             [OK]
Carga (1 minuto)         0.86 para 20 CPU(s)             [OK]

REDE
------------------------------------------------------------------------
Interface principal      interface0                      [INFO]
Endereco IPv4            endereco-local                 [INFO]
Gateway padrao           gateway-local                  [INFO]
Conectividade externa    Resposta recebida               [OK]

SERVICOS
------------------------------------------------------------------------
Servicos com falha       0                               [OK]

RESUMO
------------------------------------------------------------------------
STATUS GERAL: SAUDAVEL
```

Os valores acima são apenas demonstrativos.

---

## Classificação dos resultados

| Estado | Significado |
|---|---|
| `INFO` | Informação descritiva do sistema |
| `OK` | Indicador dentro dos parâmetros esperados |
| `ATENCAO` | Recurso que merece acompanhamento |
| `CRITICO` | Situação que pode exigir análise imediata |

---

## Requisitos

O script utiliza ferramentas normalmente disponíveis nas principais distribuições Linux:

- Bash
- awk
- grep
- sed
- df
- free
- uptime
- ip
- ping
- systemctl

O comportamento pode variar em distribuições que não utilizam `systemd`.

---

## Como utilizar

Clone o repositório:

```bash
git clone https://github.com/matheusamaro-dev/linux-server-health-check.git
```

Entre na pasta:

```bash
cd linux-server-health-check
```

Conceda permissão de execução:

```bash
chmod +x health-check.sh
```

Execute:

```bash
./health-check.sh
```

Também é possível executar diretamente com o Bash:

```bash
bash health-check.sh
```

---

## Segurança

O projeto foi desenvolvido seguindo princípios de operação segura:

- Não altera configurações
- Não reinicia o sistema
- Não encerra processos
- Não interrompe serviços
- Não instala pacotes
- Não solicita credenciais
- Não utiliza informações internas
- Executa apenas consultas ao sistema

---

## Compatibilidade

A versão `1.0.1` foi validada no seguinte ambiente:

```text
Ubuntu 26.04 LTS
Bash
Arquitetura x86_64
```

O script também foi desenvolvido para funcionar em outras distribuições Linux que possuam os comandos necessários.

---

## Estrutura do projeto

```text
linux-server-health-check/
├── health-check.sh
├── LICENSE
└── README.md
```

---

## Próximas melhorias

- Geração de relatório em arquivo
- Exportação para CSV
- Opção de saída em JSON
- Parâmetros configuráveis
- Verificação de múltiplos discos
- Monitoramento de temperatura
- Histórico de execuções
- Modo sem cores para automações
- Suporte ampliado a diferentes distribuições

---

## Autor

**Matheus Amaro**

Técnico de Manutenção, estudante de Análise e Desenvolvimento de Sistemas e desenvolvedor de soluções para monitoramento e infraestrutura.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Matheus%20Amaro-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/matheus-amaro-costa)

[![GitHub](https://img.shields.io/badge/GitHub-matheusamaro--dev-181717?style=for-the-badge&logo=github)](https://github.com/matheusamaro-dev)

---

## Licença

Este projeto está disponível sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais informações.
