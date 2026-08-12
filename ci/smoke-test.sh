#!/usr/bin/env bash
# JupyterLab smoke test. Runs *inside* a built image, e.g.
#
#   docker run --rm -i ghcr.io/oceanhackweek/python:tag bash -s < ci/smoke-test.sh
#
# Verifies the image can serve JupyterLab, create a notebook, and execute code.
# Override KERNEL_NAME / SMOKE_IMPORTS for non-Python images.
set -euo pipefail

KERNEL_NAME="${KERNEL_NAME:-python3}"
SMOKE_IMPORTS="${SMOKE_IMPORTS:-xarray, zarr, icechunk, cartopy, matplotlib}"

TOKEN=smoke-test-token
PORT=8888
BASE="http://127.0.0.1:${PORT}"
AUTH=(-H "Authorization: token ${TOKEN}")
LAB_LOG=/tmp/jupyter-lab.log

echo "== 1. CLI and kernelspecs =="
jupyter lab --version
jupyter kernelspec list 2>&1 | grep -qE "^[[:space:]]+${KERNEL_NAME}[[:space:]]" \
  || { echo "FAIL: no ${KERNEL_NAME} kernelspec"; jupyter kernelspec list; exit 1; }

echo "== 2. Lab extensions load without error =="
ext_out=$(jupyter labextension list 2>&1)
echo "${ext_out}"
if echo "${ext_out}" | grep -qiE '\b(error|problems)\b'; then
  echo "FAIL: labextension problems reported"
  exit 1
fi

echo "== 3. Launch the server =="
cd "$(mktemp -d)"
jupyter lab --no-browser --ip=127.0.0.1 --port="${PORT}" \
  --ServerApp.token="${TOKEN}" --ServerApp.open_browser=False >"${LAB_LOG}" 2>&1 &
LAB_PID=$!
trap 'kill "${LAB_PID}" 2>/dev/null || true' EXIT

# /api/status requires the token on jupyter_server >=2.14, so poll authenticated.
for _ in $(seq 1 60); do
  curl -sf "${AUTH[@]}" "${BASE}/api/status" >/dev/null 2>&1 && break
  kill -0 "${LAB_PID}" 2>/dev/null \
    || { echo "FAIL: server exited"; tail -30 "${LAB_LOG}"; exit 1; }
  sleep 2
done
curl -sf "${AUTH[@]}" "${BASE}/api/status" \
  || { echo "FAIL: /api/status never became available"; tail -30 "${LAB_LOG}"; exit 1; }
echo

echo "== 4. Lab UI page serves =="
code=$(curl -s -o /dev/null -w '%{http_code}' "${AUTH[@]}" "${BASE}/lab")
[ "${code}" = "200" ] || { echo "FAIL: /lab returned ${code}"; tail -30 "${LAB_LOG}"; exit 1; }
echo "/lab -> ${code}"

echo "== 5. Create a notebook (the request the New Notebook button makes) =="
created=$(curl -sf -X POST "${AUTH[@]}" -H 'Content-Type: application/json' \
  -d '{"type":"notebook"}' "${BASE}/api/contents") \
  || { echo "FAIL: could not create a notebook"; tail -30 "${LAB_LOG}"; exit 1; }
echo "created: $(printf '%s' "${created}" | python -c 'import json,sys; print(json.load(sys.stdin)["path"])')"

echo "== 6. Start a kernel through the API =="
kernel=$(curl -sf -X POST "${AUTH[@]}" -H 'Content-Type: application/json' \
  -d "{\"name\":\"${KERNEL_NAME}\"}" "${BASE}/api/kernels") \
  || { echo "FAIL: could not start a ${KERNEL_NAME} kernel"; tail -30 "${LAB_LOG}"; exit 1; }
kid=$(printf '%s' "${kernel}" | python -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "kernel: ${kid}"
curl -sf "${AUTH[@]}" "${BASE}/api/kernels/${kid}" >/dev/null \
  || { echo "FAIL: kernel ${kid} is not alive"; tail -30 "${LAB_LOG}"; exit 1; }
curl -sf -X DELETE "${AUTH[@]}" "${BASE}/api/kernels/${kid}"

echo "== 7. Execute a notebook end to end =="
SMOKE_IMPORTS="${SMOKE_IMPORTS}" python - <<'PY'
import os

import nbformat as nbf

imports = os.environ["SMOKE_IMPORTS"]
nb = nbf.v4.new_notebook(
    cells=[
        nbf.v4.new_code_cell(f"import {imports}; print('imports ok')"),
        nbf.v4.new_code_cell("assert 1 + 1 == 2; print('execution ok')"),
    ]
)
nbf.write(nb, "smoke.ipynb")
PY
# Both jupyter execute and nbconvert exit non-zero when a cell raises.
jupyter execute --inplace --kernel_name="${KERNEL_NAME}" smoke.ipynb
python - <<'PY'
import nbformat

nb = nbformat.read("smoke.ipynb", as_version=4)
texts = [o.get("text", "") for c in nb.cells for o in c.get("outputs", [])]
assert any("imports ok" in t for t in texts), f"missing expected output: {texts}"
assert any("execution ok" in t for t in texts), f"missing expected output: {texts}"
print("notebook executed with expected output")
PY

echo "ALL SMOKE TESTS PASSED"
