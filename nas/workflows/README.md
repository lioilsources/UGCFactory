# ComfyUI workflows pro fantasy characters

Sem patří exporty z ComfyUI (**Save (API Format)**, ne obyčejné Save) pro kroky,
které běží na Sparku. Vzniknou ve fázi 1 plánu, viz
`docs/FANTASYCHARACTER_PLAN.md` §4.

| Soubor | Krok | Co má dělat |
|---|---|---|
| `fc_preprocess.json` | `char.preprocess` | RMBG-2.0/BiRefNet → RGBA, volitelně A-pose kanonizace (SDXL + OpenPose ControlNet + IP-Adapter) |
| `fc_mesh.json` | `char.mesh` | TRELLIS image→3D → GLB s texturou |
| `fc_rig.json` | `char.rig` | UniRig (MIA mode) → FBX s `mixamorig:` kostrou |
| `fc_pipeline.json` | fallback | jeden graf pro všechny tři kroky, když se je nevyplatí dělit |

## Kontrakt s workerem

Worker nezná čísla nodů — ta se při každé editaci grafu v ComfyUI přečíslují.
Domlouvá se přes **titulek nodu** (pravý klik → Properties → Title):

- `FC_INPUT_IMAGE` — nod, kterému worker přepíše `inputs.image` na cestu ke
  vstupu daného kroku. Bez něj krok skončí chybou, ne tichým během nad starým
  obrázkem.
- `FC_SEED` — volitelné, pro reprodukovatelnost.

Výstup si worker vezme z `/history/{prompt_id}` a stáhne přes `/view`; bere
první soubor s očekávanou příponou (`.png` u preprocess, `.glb` u mesh, `.fbx`
u rig). Ať tedy graf neukládá mezivýsledky se stejnou příponou dřív než finál.

Nastav `FC_COMFY_URL` (např. `http://192.168.88.66:8188`), jinak ComfyUI kroky
selžou hned s hláškou místo timeoutu.
