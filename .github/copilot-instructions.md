# Instruções para Agentes de Código (Copilot)

Objetivo: ajudar agentes a contribuir com segurança e consistência neste repositório de scripts Shell.

**Descoberta**:
- Este repositório é uma coleção de scripts de setup/instalação organizados por pasta. Exemplos chave:
  - [cli/install-ohmyzsh.sh](cli/install-ohmyzsh.sh)
  - [github/github-cloneallrepos.sh](github/github-cloneallrepos.sh)
  - [initial-setup/essential-debian.sh](initial-setup/essential-debian.sh)
  - [network/install_docker_debian.sh](network/install_docker_debian.sh)

**Code Style (Shell)**:
- Preferir `bash` com shebang `#!/usr/bin/env bash` e `set -euo pipefail` quando aplicável.
- Seguir padrão de funções nomeadas, variáveis em MAIÚSCULAS para config, comentários curtos no topo.
- Ferramentas recomendadas: `shellcheck` para lint, `shfmt` para formatação.

**Arquitetura**:
- Cada script é independente e focado (instalar/ configurar uma ferramenta). Evitar mudanças globais não necessárias.
- Mantenha efeitos colaterais explícitos (usar `sudo` apenas onde requerido) e idempotência quando possível.

**Build & Test (comandos que agentes devem tentar)**:
- Verificar sintaxe: `bash -n <arquivo>.sh` ou `bash -n **/*.sh`
- Lint: `shellcheck **/*.sh`
- Formatar: `shfmt -w -i 2 .`
- Teste manual seguro: executar scripts em ambiente isolado/VM/contêiner antes de mesclar.

**Convenções do projeto**:
- Nomes de arquivos usam underscores e descrevem a ação (ex.: `install_docker_debian.sh`).
- Variáveis configuráveis ficam no topo do arquivo e documentadas no comentário inicial.
- Não adicionar credenciais em texto; usar variáveis de ambiente e instruir o usuário sobre como fornecê-las.

**Pontos de Integração**:
- Scripts interagem com `apt`, `brew`, `docker`, e a API do GitHub (ver [github/github-cloneallrepos.sh](github/github-cloneallrepos.sh)).
- Ao modificar integrações, documentar dependências externas e permissões necessárias.

**Segurança / Privacidade**:
- Nunca adicionar tokens ou segredos no repositório. Se um script requer um token, documente a variável de ambiente esperada.
- Evitar prints de dados sensíveis; usar redaction quando for necessário logar.

**Contribuição**:
- Abra PRs pequenas e focadas. Incluir saída do `shellcheck` e confirmação de execução manual (ou passos de reprodução).
- Agents devem executar `shellcheck` e `shfmt` automaticamente antes de propor mudanças.

Se alguma seção estiver incompleta ou contexto estiver faltando, por favor peça feedback ao mantenedor antes de mudanças arriscadas.
