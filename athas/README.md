# Атхас: «Немного знания» — вертикальный срез

Скрипты и схема сборки первых сцен модуля Dark Sun «A Little Knowledge» (TSR, 1991)
для NWN:EE. Дизайн-документ: https://claude.ai/code/artifact/ebe3742a-215c-40a8-a6ba-1cc64527c764

Режим: один герой, одиночная игра, русский язык (cp1251). Скрипты написаны так,
чтобы позже добавить компаньонов и сетевую игру без переписывания: состояние жажды
хранится на каждом персонаже, сцены проходят по всем игрокам, числа баланса лежат
в `ath_inc_const`, тексты — в `ath_inc_text`.

## 0. Перед началом: русский текст в nwn-mcp

`nwn-mcp` без доработки записывает скрипты в UTF-8, а `nwn_gff` переводит текст
в windows-1252. Кириллица в игре из-за этого ломается. Патч
[`tools/nwn-mcp-encoding.patch`](../tools/nwn-mcp-encoding.patch) добавляет
настройку `NWN_ENCODING`:

```
cd C:\tools\nwn-mcp
git apply путь\к\aurora\tools\nwn-mcp-encoding.patch
npm run build
```

Затем в конфиге Claude Desktop (и в `.mcp.json` для Claude Code) добавьте в `env`
сервера строку `"NWN_ENCODING": "windows-1251"` и перезапустите Claude.

## 1. Скрипты

Файлы в `scripts/` хранятся в UTF-8. Через пропатченный `write_script` они
записываются в модуль в cp1251. Файлы `ath_inc_*` — include: их записывают
без компиляции (`compile: false`), остальные компилируются.
У `ath_c_elf` вместо `main` функция `StartingConditional` — это условие диалога.

| Событие | Скрипт |
| --- | --- |
| Module OnModuleLoad | `ath_mod_load` |
| Module OnClientEnter | `ath_start` |
| Module OnHeartbeat | `ath_mod_hb` |
| Module OnPlayerRest | `ath_rest` |
| Module OnActivateItem | `x2_mod_def_act` (стандартный, нужен для tag-based) |
| L2 OnEnter | `ath_l2_enter` |
| L3 OnEnter | `ath_l3_enter` |

## 2. Локации

| Тег | Название | Тайлсет | Размер |
| --- | --- | --- | --- |
| `ATH_AREA_WAGON` | Повозка Решерека | `tin01` | 4×3 |
| `ATH_AREA_DESERT` | Пески у повозки | `ttd01`, день | 8×8 |
| `ATH_AREA_NIGHT` | Песчаные пустоши | `ttd01`, ночь | 12×12 |

Старт модуля — вейпоинт `ATH_WP_CHAIN` в трюме (комната F).

## 3. Объекты по локациям

### L1 «Повозка Решерека»

| Что | Тег / ресреф | Настройка |
| --- | --- | --- |
| Вейпоинт привязи (старт) | `ATH_WP_CHAIN` | в трюме F |
| Триггер привязи | любой | радиус ~3 м вокруг `ATH_WP_CHAIN`, OnExit `ath_chain_exit` |
| Костяная петля | плейсибл `ath_bone_loop` | Useable, OnUsed `ath_s1_loop` |
| Двери трюма (2 шт.) | `ATH_HOLD_DOOR` | заперты, без ключа, Plot |
| Дверь наружу | `ATH_WAGON_DOOR` | переход в L2 на `ATH_WP_L2_ARRIVE` |
| Голос эльфов | плейсибл-невидимка `ATH_VOICE` | у внешней стены |
| Охранник трюма | `ath_crew_hold`, тег `ATH_CREW_HOLD` | диалог `ath_dlg_guard` |
| Охранники (4 шт.) | `ath_crew_guard`, тег `ATH_CREW_GUARD` | |
| Псионик | `ath_crew_psion`, тег `ATH_CREW_PSION` | диалог `ath_dlg_psion` |
| Вейпоинты | `ATH_WP_LIGHTNING`, `ATH_WP_DECK`, `ATH_WP_BOARD` | удар молнии, боевой пост, вход эльфов |
| Комнаты A–E | контейнеры | A: обсидиановое оружие; C: 25 монет; D: сейф с ловушкой (яд), 25 монет и `ath_map`; E: 20 × `ath_water_q` |

Экипаж — фракция «Решерек» (нейтральна к игроку). Все теги экипажа начинаются
с `ATH_CREW`: по этому префиксу эльфы добивают их в `ath_s2_elves`.

### L2 «Пески у повозки»

| Что | Тег / ресреф | Настройка |
| --- | --- | --- |
| Вейпоинт прибытия | `ATH_WP_L2_ARRIVE` | у двери повозки |
| Части повозки | плейсиблы с тегом `ATH_WAGON_PART` | исчезают после пожара |
| Вождь | `ath_elf_chief`, тег `ATH_ELF_CHIEF` | диалог `ath_dlg_chief`, фракция «Джура-Дай» |
| Эльфы (20–25 шт.) | `ath_elf_raider`, тег `ATH_ELF` | фракция «Джура-Дай», нейтральна к игроку |
| Точки огня | вейпоинты `ATH_WP_FIRE` (5–8 шт.) | на корпусе повозки |
| Остов | вейпоинты `ATH_WP_WRECK` (2–3 шт.) | на месте повозки |
| Тайник с находками | вейпоинт `ATH_WP_CACHE` | там появится `ath_wreck_cache` |
| Уход эльфов | вейпоинт `ATH_WP_ELF_EXIT` | край карты |
| Жаждущие охранники | вейпоинты `ATH_WP_GUARDS`, `ATH_WP_GUARDS_EXIT` | появление и уход на СВ |
| Триггер пепелища | любой | вокруг повозки, OnEnter `ath_s4_wreck` |
| Триггеры перед выходами | любые | у выходов СВ и ЮЗ, OnEnter `ath_s4_exit` |
| Тень | триггеры | у скал, OnEnter `ath_shade_in`, OnExit `ath_shade_out` |
| Дорога на Урик | триггер у СВ края | OnEnter `ath_urik_road` |
| Переход в L3 | триггер у ЮЗ края | на вейпоинт в L3 |

### L3 «Песчаные пустоши»

| Что | Тег / ресреф | Настройка |
| --- | --- | --- |
| Чаща тимириса | плейсиблы `ath_timiris`, тег `ATH_TIMIRIS` | кольцо колючих кустов, разрушаемые |
| Тоннель | триггер на середине прохода в чащу | OnEnter `ath_s6_tunnel` |
| «Пруд» | плейсибл `ath_pool` | Useable, OnUsed `ath_s6_pool` |
| Конец среза | триггер у ЮЗ края | OnEnter `ath_end` |

## 4. Шаблоны предметов

| Ресреф и тег | Название | Базовый предмет и свойства |
| --- | --- | --- |
| `ath_water_q` | Кувшин воды (кварта) | Potion; Cast Spell: Unique Power Self Only (Single Use); стопка до 10 |
| `ath_loincloth` | Набедренная повязка | Armor, ткань, AC 0 |
| `ath_xbow` | Арбалет охраны | Light Crossbow |
| `ath_bolt_obs` | Обсидиановый болт | Bolt; Damage Penalty 1 |
| `ath_wpn_thirsty` | Обсидиановый короткий меч | Short Sword; Attack Penalty 2; Damage Penalty 1; On Hit Cast Spell: OnHit Unique Power |
| `ath_map` | Карта капитана Веома | Misc; описание: цепочка крестиков от Урика, дальше на юго-запад к оазису и Кледу |
| `ath_thorns_pull` | Шипы тимириса | Misc; Cast Spell: Unique Power Self Only (Single Use); описание: «Использовать — вытащить шипы» |
| `ath_charcoal` | Уголь | Misc |
| `ath_obs_shard` | Обсидиановый осколок | Dagger; Attack Penalty 2 |
| `ath_glass` | Стекло из оплавленного песка | Misc |

Тег у `ath_water_q`, `ath_wpn_thirsty` и `ath_thorns_pull` должен совпадать
с ресрефом: по тегу вызывается одноимённый tag-based скрипт.

## 5. Шаблоны существ и плейсиблов

| Ресреф | Тег | Заметки |
| --- | --- | --- |
| `ath_crew_hold` | `ATH_CREW_HOLD` | человек, обсидиановый меч |
| `ath_crew_guard` | `ATH_CREW_GUARD` | человек, обсидиановый меч |
| `ath_crew_psion` | `ATH_CREW_PSION` | человек, кинжал |
| `ath_elf_raider` | `ATH_ELF` | эльф, костяной меч, факел |
| `ath_elf_chief` | `ATH_ELF_CHIEF` | эльф 4 HD, кожаный нагрудник канка, стальной кинжал |
| `ath_thirsty` | `ATH_THIRSTY` | человек, оружие `ath_wpn_thirsty`, фракция Commoner |
| `ath_thirsty_ldr` | `ATH_THIRSTY_LDR` | то же + диалог `ath_dlg_thirsty` |
| `ath_wreck` | любой | обгоревший остов (статичный плейсибл) |
| `ath_wreck_cache` | любой | контейнер «Обломки повозки» |
| `ath_bone_loop`, `ath_timiris`, `ath_pool` | см. выше | |

Пламя — стандартный `plc_flamelarge`. Если ресреф в вашей версии игры другой,
поменяйте `ATH_RES_FLAME` в `ath_inc_const`.

## 6. Диалоги

Тексты реплик — в разделе «Диалоги» дизайн-документа. Скрипты Action Taken:

| Диалог | Ответ игрока | Скрипт |
| --- | --- | --- |
| `ath_dlg_psion` | «Согласен» | `ath_psion_agree` |
| `ath_dlg_psion` | «А если нет?» | `ath_psion_refuse` |
| `ath_dlg_psion` | «Попробуй заставь» | `ath_psion_resist` |
| `ath_dlg_chief` | «Я ухожу» | `ath_confiscate` |
| `ath_dlg_chief` | «Вода и оружие — моё» | `ath_chief_hostile` |
| `ath_dlg_thirsty` | «Держи» | `ath_thirsty_give` |
| `ath_dlg_thirsty` | «Половину» | `ath_thirsty_half` |
| `ath_dlg_thirsty` | «Только подойди» | `ath_thirsty_scare` |
| `ath_dlg_thirsty` | «В Урике вас самих закуют…» | `ath_thirsty_bluff` |
| `ath_dlg_thirsty` | [Атака] | `ath_thirsty_fight` |

Ветки «Почему вы напали?» и «Возьмите меня с собой» в `ath_dlg_chief` видны
только эльфам: Text Appears When — `ath_c_elf`.

## 7. Журнал

Квест `ath_survive` «Выжить»:

| Этап | Текст |
| --- | --- |
| 1 | Я раб в трюме повозки торгового дома Решерек. Её везут из Урика в Тир, на строительство зиккурата. |
| 2 | На караван напали эльфы. Охрана забыла о рабах — сейчас или никогда. |
| 3 | Эльфы Джура-Дай забирают повозку. Мне оставили немного воды и велели уходить. |
| 4 | Охранники каравана тоже выжили, и им нужна вода — любой ценой. |
| 5 | Иду на юго-запад. Днём пекло, ночью идти легче: воды нужно вдвое меньше. |
| 6 | Серебряный блеск в колючих зарослях оказался ловушкой. |
| 7 | Я пережил первую ночь в пустыне. (Конец среза.) |

## 8. Порядок сборки через nwn-mcp

1. Применить патч кодировки (раздел 0).
2. Создать модуль и три локации, связать переходы.
3. Создать шаблоны предметов, существ и плейсиблов (разделы 4–5).
4. Расставить объекты (раздел 3).
5. Записать скрипты: сначала `ath_inc_*` без компиляции, потом остальные с компиляцией.
6. Привязать события модуля, локаций, триггеров и плейсиблов.
7. Создать диалоги и журнал (разделы 6–7).
8. `validate_module`, `find_orphans`, `repack_module`, затем плейтест.

Скрипты здесь не компилировались: в облаке нет `nwscript.nss` и стандартных
include-файлов игры. Ошибки компиляции покажет `compile_script` локально.
