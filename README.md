<div align="center">

<img src="assets/retrocrate.svg" alt="RetroCrate" width="104" />

# RetroCrate

**Um ambiente de emulação reproduzível para Linux, empacotado com Distrobox.**

[![Distrobox](https://img.shields.io/badge/Distrobox-manifest-5e81ac?style=flat-square)](https://distrobox.it/)
[![Arch Linux](https://img.shields.io/badge/packages-Arch%20Linux-1793d1?style=flat-square)](https://archlinux.org/packages/)
[![License: MIT](https://img.shields.io/badge/license-MIT-2e7d32?style=flat-square)](LICENSE)

</div>

RetroCrate prepara uma caixa Arch Linux sem privilégios de root para executar um conjunto curado de emuladores e cores do RetroArch. O ambiente é descrito em manifestos, pode ser pré-visualizado antes da criação e integra os aplicativos ao menu do Linux host.

> **Status:** primeira versão utilizável. O escopo é intencionalmente menor que o de uma distribuição de jogos completa: sem frontend de biblioteca, instaladores de terceiros, ROMs, BIOS ou configurações específicas de uma máquina.

## O que vem incluído

| Aplicativo/pacote | Uso |
| --- | --- |
| [RetroArch](https://archlinux.org/packages/extra/x86_64/retroarch/) + [assets Ozone](https://archlinux.org/packages/extra/any/retroarch-assets-ozone/) | Frontend para cores Libretro |
| [mGBA](https://archlinux.org/packages/extra/x86_64/libretro-mgba/), [Snes9x](https://archlinux.org/packages/extra/x86_64/libretro-snes9x/), [Genesis Plus GX](https://archlinux.org/packages/extra/x86_64/libretro-genesis-plus-gx/) | Cores para plataformas clássicas |
| [Mupen64Plus Next](https://archlinux.org/packages/extra/x86_64/libretro-mupen64plus-next/), [Beetle PSX](https://archlinux.org/packages/extra/x86_64/libretro-beetle-psx/), [PPSSPP](https://archlinux.org/packages/extra/x86_64/libretro-ppsspp/), [MAME](https://archlinux.org/packages/extra/x86_64/libretro-mame/) | Cores Libretro adicionais |
| [Dolphin](https://archlinux.org/packages/extra/x86_64/dolphin-emu/) | Emulação de GameCube e Wii |
| [PPSSPP](https://archlinux.org/packages/extra/x86_64/ppsspp/) | Emulação de PSP |
| [MAME](https://archlinux.org/packages/extra/x86_64/mame/) | Emulação de arcade |

Os pacotes são solicitados pelos nomes dos repositórios oficiais do Arch Linux. A disponibilidade pode variar por arquitetura e mudar ao longo do tempo; a versão inicial foi montada para hosts Linux `x86_64`.

## Requisitos e limites

- Host Linux `x86_64` com Distrobox e Podman ou Docker instalados e funcionando.
- Conexão à internet e espaço em disco para a imagem e os emuladores.
- Uma sessão gráfica funcional no host para abrir os emuladores.
- **Windows nativo e macOS não são alvos suportados.** WSL pode exigir configuração própria de vídeo, áudio, GPU e dispositivos; não é validado por este projeto.
- A integração `--gpu nvidia` usa drivers proprietários NVIDIA já instalados no host. Ela não instala nem corrige drivers. Para AMD/Intel, use o manifesto padrão.

### Importante sobre isolamento

Distrobox é uma camada de compatibilidade e empacotamento, não uma fronteira de segurança. Por padrão, o container compartilha a pasta pessoal, arquivos, dispositivos e partes da sessão gráfica/áudio do host. Não execute ROMs, scripts ou binários desconhecidos esperando que o container os torne seguros.

## Instalação

Clone o repositório no host Linux:

```bash
git clone https://github.com/paulo-santzs/retrocrate.git
cd retrocrate
```

Primeiro veja o comando que seria executado — esta etapa não cria nem altera container algum:

```bash
./scripts/setup.sh
```

Se a prévia estiver correta, crie o ambiente:

```bash
./scripts/setup.sh --apply
```

Para um host com GPU NVIDIA e drivers proprietários já instalados:

```bash
./scripts/setup.sh --gpu nvidia
./scripts/setup.sh --gpu nvidia --apply
```

A configuração não substitui caixas existentes (`replace=false`). Os scripts não instalam pacotes no host e não removem containers automaticamente. A imagem é baixada durante a criação; **na primeira entrada interativa**, o Distrobox inicializa o Arch e instala os pacotes. Essa etapa pode levar alguns minutos.

## Usar

Entre no ambiente em um terminal interativo e espere a primeira instalação terminar:

```bash
distrobox enter retrocrate
```

O manifesto solicita a exportação dos atalhos do RetroArch, Dolphin, PPSSPP e MAME para o menu de aplicativos do host. Se precisar refazer essa exportação depois:

```bash
./scripts/export-apps.sh
```

Para conferir o ambiente:

```bash
./scripts/doctor.sh
```

Para atualizar os pacotes dentro da caixa:

```bash
distrobox enter retrocrate -- sudo pacman -Syu
```

Os atalhos e a caixa usam a integração normal do Distrobox; a disponibilidade de vídeo acelerado depende do host, drivers, sessão gráfica e configuração do container. Rode o diagnóstico e teste cada aplicativo no seu hardware.

## ROMs, BIOS e conteúdo de jogos

RetroCrate **não distribui** jogos, ROMs, BIOS, firmware, chaves, imagens de disco nem conteúdo protegido. O usuário deve obter e usar esses arquivos de acordo com a legislação aplicável e os termos dos titulares. O projeto também não configura nem valida arquivos de BIOS necessários para determinados emuladores.

Guarde seu conteúdo pessoal fora deste repositório. A pasta pessoal do host é compartilhada com a caixa; você pode criar, por exemplo, `~/Games/roms` e apontar as bibliotecas dos emuladores para lá.

## GPU e diagnóstico

O padrão (`nvidia=false`) deixa a integração de GPU a cargo do host. `distrobox-nvidia.ini` ativa apenas a integração NVIDIA oferecida pelo Distrobox; é necessário que o driver proprietário compatível já esteja instalado no host. Isso não garante aceleração em todo hardware ou configuração.

O script de diagnóstico confere dependências, existência da caixa e presença dos executáveis principais:

```bash
./scripts/doctor.sh
```

Problemas de desempenho devem ser investigados também no host (driver, Mesa/Vulkan, sessão Wayland/X11, permissões e dispositivo gráfico). Não há telemetria, upload de dados ou benchmark automático neste projeto.

## Configuração

Os manifestos são deliberadamente simples:

- [`distrobox.ini`](distrobox.ini): configuração padrão.
- [`distrobox-nvidia.ini`](distrobox-nvidia.ini): mesmo conjunto de pacotes, com integração NVIDIA habilitada.
- `replace=false`: uma atualização do manifesto não apaga nem recria uma caixa existente.
- `root=false` e `init=false`: caixa de usuário, sem sistema init separado.

Para personalizar a lista, edite `additional_packages` usando nomes de pacotes válidos para a arquitetura. Antes de aplicar alterações, faça uma prévia com `distrobox assemble create --file distrobox.ini --dry-run`. Alterações em uma caixa já criada devem ser instaladas/atualizadas dentro dela; o manifesto não é um gerenciador de migrações.

## Remover

O script exige que você digite o nome exato da caixa antes de removê-la:

```bash
./scripts/remove.sh
```

Ele remove apenas o container `retrocrate`. Arquivos no seu HOME (incluindo ROMs, saves e configurações) não são removidos.

## Por que este projeto é diferente

RetroCrate foi criado independentemente a partir da ideia geral de descrever um ambiente de jogos em container. Não reutiliza código, documentação ou configurações específicas de outros repositórios. Prioriza manifestos pequenos, pacotes oficiais, uma prévia antes de qualquer criação e limites explícitos. Não busca reproduzir todas as funcionalidades do projeto que inspirou a ideia.

## Desenvolvimento

Contribuições pequenas e reproduzíveis são bem-vindas. Veja [`CONTRIBUTING.md`](CONTRIBUTING.md) e [`SECURITY.md`](SECURITY.md). Não envie ROMs, BIOS, firmware, dumps de jogos, credenciais ou arquivos pessoais.

## Referências técnicas

- [Distrobox: criação de containers](https://distrobox.it/usage/distrobox-create/)
- [Distrobox: manifestos e assemble](https://distrobox.it/usage/distrobox-assemble/)
- [Distrobox: exportação de aplicativos](https://distrobox.it/usage/distrobox-export/)
- [Pacotes oficiais do Arch Linux](https://archlinux.org/packages/)

## English summary

RetroCrate is an original, manifest-driven Distrobox setup for a curated set of official Arch Linux emulators and Libretro cores. It supports a preview-before-create workflow and optional NVIDIA driver integration. It targets Linux x86_64; it does not provide games, ROMs, BIOS or firmware, and Distrobox is not a security sandbox. See the Portuguese guide above for setup and operational details.
