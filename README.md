# Zedja Custom Cards

Custom cards for EDOPro, scripted by Zedja.

## Contents

| Path | Content |
|---|---|
| `*.cdb` | Card databases (stats, texts, client strings), one per archetype; see the tables below |
| `script/` | One Lua script per card, named `c<passcode>.lua` |
| `pics/`, `pics/thumbnail/` | Card images, named `<passcode>.jpg` |
| `strings.conf` | Archetype names (`!setname`) for the custom setcodes only |

`strings.conf` intentionally contains only the custom entries. EDOPro merges it with the
official strings, so copying the official file here would override newer official strings
with stale ones.

## Installing in EDOPro

Add this repository to the `repos` list of your EDOPro user configuration
(`config/user_configs.json`), using the same fields as the other entries in your client's
`config/configs.json`, for example:

```json
{
	"url": "https://github.com/zedja123/ZedjaCustomCards",
	"repo_name": "Zedja Custom Cards",
	"repo_path": "./repositories/zedja-custom-cards",
	"data_path": "",
	"script_path": "script",
	"pics_path": "pics",
	"should_update": true,
	"should_read": true
}
```

Restart the client after editing the file. Field names can change between client versions;
if in doubt, copy an existing entry from `configs.json` and adjust the URL and paths.

## Archetypes

Passcodes follow `270000000 + 100*(archetype-1) + n`; Tokens take numbers from the end of
their archetype's block. Setcodes follow `0xe00 + (archetype-1)`; sub-archetypes use the high
nibble.

| # | Archetype | Passcodes | Setcode | Database |
|---|---|---|---|---|
| 1 | "Prismiant" | 270000001-270000011 | `0xe00` | `Prismiant.cdb` |
| 2 | "Wiccanthrope" | 270000101-270000113 | `0xe01` | `Wiccanthrope.cdb` |
| 3 | "Ashens" | 270000201-270000210, Token 270000299 | `0xe02` | `Ashens.cdb` |
| 4 | "Lavoisier" / "Lavoisier Arsenal" | 270000301-270000315 | `0xe03` / `0x1e03` | `Lavoisier.cdb` |
| 5 | "Build Rider" / "Build Driver" | 270000401-270000415 | `0x1e04` / `0x2e04` | `BuildRider.cdb` |
| 6 | "Milacresy" | 270000501-270000513 | `0xe05` | `Milacresy.cdb` |

A new card goes into the database of its archetype; a new archetype gets its own database,
named after the archetype.

Legacy passcodes kept so existing decks keep working:

| Passcode(s) | Card(s) | Note | Database |
|---|---|---|---|
| 270000099 | "Albaz, the Fallen" | Standalone card at the end of block 1 | `AlbazTheFallen.cdb` |
| 271000001-271000004 | "Fire King" support | Uses the official "Fire King" setcode (`0x81`) | `FireKingCustoms.cdb` |
| 272000001-272000005 | "Gimmick Puppet" support | Uses the official "Gimmick Puppet"/"Puppet" setcodes | `GimmickPuppetCustoms.cdb` |
| 27999999 | "Revolution des Fleurs" | Duel Links Skill | `DuelLinksSkills.cdb` |

## Conventions

* Card text follows Konami's Problem-Solving Card Text (PSCT).
* Script header:

  ```lua
  --
  --<Card Name>
  --scripted by Zedja
  local s,id=GetID()
  local SET_PRISMIANT=0xe00
  ```

  The custom setcode is declared as a file-local constant; official setcodes use the
  constants from CardScripts (`SET_FIRE_KING`, ...).
* One block per effect, in text order, each preceded by the verbatim effect text as a
  comment; every activated effect has a description string (`aux.Stringid(id,n)` =
  database `str(n+1)`).
* Tabs, LF line endings, UTF-8.

## Verifying changes

The scripting workflow, documentation and tools live in the CardScripts fork
(`.claude/skills/edopro-card-scripting/` and `docs/`). The linter enables its custom-card
checks only for scripts in a folder named `ZedjaCustomCards`, so copy `script/*.lua` and
the `*.cdb` files into such a folder next to the CardScripts checkout, then run:

```bash
T=CardScripts/.claude/skills/edopro-card-scripting/tools
python3 $T/lint.py --cdb ZedjaCustomCards ZedjaCustomCards/*.lua
python3 $T/loadcheck.py run ZedjaCustomCards/*.lua   # run "loadcheck.py setup" once first
```
