#!/bin/bash
# publish.sh — hospedado no repo publico. Chamado pela rotina via:
#   curl -fsSL https://raw.githubusercontent.com/mispace/ourspace-office/main/publish.sh | bash
# Gera status.json (Trello) -> cifra (OFFICE_KEY) -> publica agents.enc/status.enc no
# repo publico (GH_OFFICE_TOKEN). Reporta cada etapa no Slack ($SLACK_WEBHOOK).
# NAO contem nenhum segredo — todos vem de env vars.
set +e
WH="$SLACK_WEBHOOK"
rep(){ curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"[escritorio] $1\"}" "$WH" >/dev/null 2>&1; }
red(){ sed 's#x-access-token:[^@]*@#TOKEN@#g'; }
fail(){ rep "FALHOU em: $1"; exit 1; }

rep "1/7 iniciou (script hospedado)"
for v in TRELLO_KEY TRELLO_TOKEN OFFICE_KEY GH_OFFICE_TOKEN; do
  eval "x=\${$v}"
  [ -z "$x" ] && fail "env $v faltando"
done
rep "2/7 env ok"

rm -rf /tmp/src
git clone --depth 1 -b design/office-visual-v6 "https://x-access-token:${GH_OFFICE_TOKEN}@github.com/mispace/michelle-analytics-agents.git" /tmp/src 2>/tmp/e || fail "clone fonte: $(tail -c 160 /tmp/e | red | tr -d '\n')"
rep "3/7 clonou fonte"

cd /tmp/src/living-os/09_office || fail "cd office"
pip install --user --quiet cffi cryptography >/dev/null 2>&1
python3 -c "import cryptography.hazmat.primitives.ciphers.aead" 2>/dev/null || fail "cryptography indisponivel"
rep "4/7 cripto ok"

python3 build_status.py --out status.json >/tmp/bs 2>&1 || fail "build_status: $(tail -c 160 /tmp/bs | tr -d '\n')"
rep "5/7 status gerado"

python3 publish_office.py >/tmp/pb 2>&1 || fail "publish_office: $(tail -c 160 /tmp/pb | tr -d '\n')"
[ -f public/agents.enc ] && [ -f public/status.enc ] || fail "sem .enc apos publish"
rep "6/7 cifrou"

rm -rf /tmp/oo
git clone --depth 1 "https://x-access-token:${GH_OFFICE_TOKEN}@github.com/mispace/ourspace-office.git" /tmp/oo 2>/tmp/e || fail "clone publico: $(tail -c 160 /tmp/e | red | tr -d '\n')"
cp -f public/office.html /tmp/oo/office.html
cp -rf public/assets /tmp/oo/
cp -f public/agents.enc public/status.enc public/CNAME public/README.md /tmp/oo/
cd /tmp/oo && git add -A
if git diff --cached --quiet; then
  rep "7/7 OK sem mudancas (nada novo)"
  exit 0
fi
git -c user.email="office@ourspace" -c user.name="Living OS" commit -m "Atualizar estado do escritorio" >/dev/null 2>&1 || fail "commit"
git push origin HEAD:main 2>/tmp/e || fail "push: $(tail -c 160 /tmp/e | red | tr -d '\n')"
rep "7/7 PUBLICOU com sucesso"
