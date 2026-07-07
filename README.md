# Living OS — Office (view pública, dados cifrados)

Esta é a "planta" do escritório vivo do Living OS: uma página estática
(`office.html`) que desenha mesas/personagens e uma linha do tempo de eventos a
partir de dois arquivos de dados.

## Por que isto é público mas não é uma exposição de dados

Os dados (`agents.enc`, `status.enc`) são publicados **cifrados** (AES-256-GCM,
chave derivada de senha via PBKDF2-SHA256, 200000 iterações). A página pede a
senha e decifra tudo no navegador de quem acessa — sem a senha certa, o
conteúdo é ilegível (não é "senha em HTML", é proteção criptográfica real). Não
há nenhuma credencial, token ou dado sensível em texto claro neste repositório.

## Hospedar (GitHub Pages) — passos que só a dona do repo pode fazer

1. Settings → Pages → **Deploy from branch** → branch `main`, pasta `/(root)`.
2. DNS: criar um registro `CNAME` apontando `office` → `mispace.github.io`
   (ou o host que o GitHub Pages indicar). O arquivo `CNAME` já está incluído
   aqui com o subdomínio configurado (`office.ourspace.com.br`).

## Como os dados chegam aqui

Publicados por `publish_office.py`, rodado a partir do repo privado
(`living-os/09_office/`). Nunca editar `agents.enc`, `status.enc` ou
`office.html` diretamente neste repositório público — qualquer mudança deve
vir de uma nova publicação a partir da fonte.
