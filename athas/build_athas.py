#!/usr/bin/env python3
"""Сборка вертикального среза «Атхас: Немного знания» (athas-alk.mod).

Тайлы трёх локаций кладёт nwn-mcp (у него есть солвер тайлсетов). Этот
скрипт берёт такой модуль и добавляет всё остальное: шаблоны, объекты,
триггеры, диалоги, журнал, фракции, события и скомпилированные скрипты.
Повторный запуск собирает модуль заново из тех же исходников.

    python athas/build_athas.py --base athas-tiles.mod -o athas-alk.mod

--base  модуль с тайлами локаций ath_wagon, ath_desert, ath_night;
--game  папка игры (для шаблонов игры и nwscript.nss);
--tools папка neverwinter.nim (nwn_resman_extract, nwn_script_comp).
"""

import argparse
import copy
import math
import os
import subprocess
import sys
import tempfile
import uuid

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))

from nwnmod import gff  # noqa: E402
from nwnmod.erf import read_erf, write_erf  # noqa: E402
from nwnmod.gff import (BYTE, CEXOLOCSTRING, CEXOSTRING, DWORD, FLOAT, INT,  # noqa: E402
                        LIST, RESREF, SHORT, VOID, WORD, LocString, Struct)

gff.ENCODING = "cp1251"

SCRIPTS_DIR = os.path.join(HERE, "scripts")
AREA_WAGON, AREA_DESERT, AREA_NIGHT = "ath_wagon", "ath_desert", "ath_night"

# Шаблоны игры, из которых клонируются шаблоны модуля.
BASE_RESREFS = [
    "nw_it_mpotion001.uti", "nw_cloth001.uti", "nw_wbwxl001.uti", "nw_wambo001.uti",
    "nw_wswss001.uti", "nw_wswdg001.uti", "nw_it_mmidmisc05.uti", "nw_it_msmlmisc06.uti",
    "nw_it_msmlmisc22.uti", "nw_it_gold001.uti",
    "nw_guard.utc", "nw_gypsy002.utc", "nw_drowfight001.utc", "nw_drowfight005.utc",
    "nw_bandit001.utc", "nw_bandit003.utc",
    "plc_bones.utp", "tm_pl_bushlg01.utp", "nw_plc_puddle1.utp", "plc_ruinwagon.utp",
    "plc_rubble.utp", "plc_invisobj.utp", "plc_box1.utp", "plc_barrel.utp",
    "plc_chest1.utp", "plc_chest4.utp", "tm_pl_caravan2.utp", "plc_fullwagon.utp",
    "plc_emptywagon.utp", "x0_desertboulder.utp",
    "nw_door_normal.utd", "nw_door_strong.utd",
]

# Свойства предметов (itempropdef.2da и связанные таблицы).
IP_CAST_SPELL, IP_UNIQUE_SELF, IP_SINGLE_USE = 15, 335, 1        # iprp_spells / iprp_chargecost
IP_ATTACK_PENALTY, IP_DAMAGE_PENALTY, IP_NEG5COST = 10, 21, 20
IP_ONHIT_CAST, IP_ONHIT_UNIQUE, IP_ONHIT_COST = 82, 125, 26
TRAP_MINOR_GAS = 24                                              # traps.2da

FACTION_HOSTILE, FACTION_COMMONER = 1, 2


def loc(text):
    return LocString({0: text})


# --------------------------------------------------------------------------
# GFF helpers

def fset(s, label, ftype, value):
    """Set a field, replacing it if present."""
    for i, (lbl, _, _) in enumerate(s.fields):
        if lbl == label:
            s.fields[i] = (label, ftype, value)
            return s
    s.fields.append((label, ftype, value))
    return s


def fdel(s, *labels):
    s.fields = [f for f in s.fields if f[0] not in labels]
    return s


def prop(name, subtype=0, cost_table=0, cost_value=0):
    return Struct(0, [
        ("PropertyName", WORD, name), ("Subtype", WORD, subtype),
        ("CostTable", BYTE, cost_table), ("CostValue", WORD, cost_value),
        ("Param1", BYTE, 255), ("Param1Value", BYTE, 255),
        ("ChanceAppear", BYTE, 100),
    ])


def unique_self():
    return prop(IP_CAST_SPELL, IP_UNIQUE_SELF, 3, IP_SINGLE_USE)


def attack_penalty(n):
    return prop(IP_ATTACK_PENALTY, 0, IP_NEG5COST, n)


def damage_penalty(n):
    return prop(IP_DAMAGE_PENALTY, 0, IP_NEG5COST, n)


def onhit_unique():
    return prop(IP_ONHIT_CAST, IP_ONHIT_UNIQUE, IP_ONHIT_COST, 1)


def facing(deg):
    r = math.radians(deg)
    return math.cos(r), math.sin(r)


# --------------------------------------------------------------------------

class Builder:
    def __init__(self, base_mod, game, tools, work):
        self.game, self.tools, self.work = game, tools, work
        _, res = read_erf(open(base_mod, "rb").read())
        self.res = {(r.lower(), e): d for r, e, d in res}
        self.base = {}
        self.blueprints = {}       # (resref, ext) -> Struct
        self.gits = {}
        self.extract_base()

    # ---- base templates -----------------------------------------------
    def extract_base(self):
        cache = os.path.join(self.work, "base")
        os.makedirs(cache, exist_ok=True)
        missing = [n for n in BASE_RESREFS if not os.path.exists(os.path.join(cache, n))]
        if missing:
            subprocess.run([os.path.join(self.tools, "nwn_resman_extract.exe"),
                            "--root", self.game, "-d", cache] + missing,
                           check=True, capture_output=True)
        for n in BASE_RESREFS:
            _, s = gff.read_gff(open(os.path.join(cache, n), "rb").read())
            self.base[n] = s

    def clone(self, name):
        return copy.deepcopy(self.base[name])

    def read(self, resref, ext):
        return gff.read_gff(self.res[(resref, ext)])[1]

    def put(self, resref, ext, s):
        self.res[(resref, ext)] = gff.write_gff(s, ext.upper().ljust(4))

    # ---- items ----------------------------------------------------------
    def item(self, resref, base, name, desc="", props=(), stack=1, plot=0, cost=None):
        s = self.clone(base)
        fset(s, "TemplateResRef", RESREF, resref)
        fset(s, "Tag", CEXOSTRING, resref)
        fset(s, "LocalizedName", CEXOLOCSTRING, loc(name))
        fset(s, "Description", CEXOLOCSTRING, loc(desc))
        fset(s, "DescIdentified", CEXOLOCSTRING, loc(desc))
        fset(s, "PropertiesList", LIST, list(props))
        fset(s, "StackSize", WORD, stack)
        fset(s, "Plot", BYTE, plot)
        fset(s, "Identified", BYTE, 1)
        if cost is not None:
            fset(s, "Cost", DWORD, cost)
        fset(s, "Comment", CEXOSTRING, "Атхас")
        self.blueprints[(resref, "uti")] = s
        return s

    def build_items(self):
        self.item("ath_water_q", "nw_it_mpotion001.uti", "Кувшин воды (кварта)",
                  "Глиняный кувшин, в нём кварта тёплой воды. На Атхасе это дороже серебра.",
                  [unique_self()], cost=10)
        self.item("ath_loincloth", "nw_cloth001.uti", "Набедренная повязка",
                  "Грязная тряпка. Больше рабу ничего не положено.", cost=0)
        self.item("ath_xbow", "nw_wbwxl001.uti", "Арбалет охраны",
                  "Лёгкий арбалет из кости и жил. Ложе в зарубках.")
        self.item("ath_bolt_obs", "nw_wambo001.uti", "Обсидиановый болт",
                  "Болт с наконечником из чёрного стекла. Колется о доспех.",
                  [damage_penalty(1)])
        self.item("ath_wpn_thirsty", "nw_wswss001.uti", "Обсидиановый короткий меч",
                  "Лезвие из сколотого обсидиана на костяной рукояти.",
                  [attack_penalty(2), damage_penalty(1), onhit_unique()])
        self.item("ath_map", "nw_it_mmidmisc05.uti", "Карта капитана Веома",
                  "Кожаный лоскут. От Урика тянется цепочка крестиков, дальше на юго-запад: "
                  "оазис, а за ним Клед.", plot=1)
        self.item("ath_thorns_pull", "nw_it_msmlmisc06.uti", "Шипы тимириса",
                  "Полые шипы торчат из кожи и тянут кровь. Использовать — вытащить шипы.",
                  [unique_self()])
        self.item("ath_charcoal", "nw_it_msmlmisc06.uti", "Уголь",
                  "Уголь из сгоревшей повозки.")
        self.item("ath_obs_shard", "nw_wswdg001.uti", "Обсидиановый осколок",
                  "Острый осколок, обмотанный тряпкой. Сойдёт за кинжал.",
                  [attack_penalty(2)])
        self.item("ath_glass", "nw_it_msmlmisc22.uti", "Стекло из оплавленного песка",
                  "Мутный зеленоватый комок. Песок оплавился в жаре пожара.")

    def item_instance(self, resref, stack=1, pos=0):
        s = copy.deepcopy(self.blueprints[(resref, "uti")]) if (resref, "uti") in self.blueprints \
            else self.clone(resref + ".uti")
        fset(s, "StackSize", WORD, stack)
        fdel(s, "PaletteID", "Comment")
        s.type = pos
        fset(s, "Repos_PosX", WORD, pos % 4)
        fset(s, "Repos_Posy", WORD, pos // 4)
        return s

    # ---- creatures --------------------------------------------------------
    def creature(self, resref, base, tag, first, last="", desc="", faction=FACTION_COMMONER,
                 conversation="", appearance=None, gender=None, race=None, equip=None,
                 plot=0, keep_equip=True):
        s = self.clone(base)
        fset(s, "TemplateResRef", RESREF, resref)
        fset(s, "Tag", CEXOSTRING, tag)
        fset(s, "FirstName", CEXOLOCSTRING, loc(first))
        fset(s, "LastName", CEXOLOCSTRING, loc(last))
        fset(s, "Description", CEXOLOCSTRING, loc(desc))
        fset(s, "FactionID", WORD, faction)
        fset(s, "Conversation", RESREF, conversation)
        fset(s, "Plot", BYTE, plot)
        if appearance is not None:
            fset(s, "Appearance_Type", WORD, appearance)
        if gender is not None:
            fset(s, "Gender", BYTE, gender)
        if race is not None:
            fset(s, "Race", BYTE, race)
        eq = [e for e in s.get("Equip_ItemList", []) if keep_equip
              and not e.get("EquippedRes", "").startswith("nw_it_cre")]
        for slot, res in (equip or {}).items():
            eq = [e for e in eq if e.type != slot]
            eq.append(Struct(slot, [("EquippedRes", RESREF, res)]))
        fset(s, "Equip_ItemList", LIST, eq)
        fset(s, "ItemList", LIST, [])
        fset(s, "Comment", CEXOSTRING, "Атхас")
        self.blueprints[(resref, "utc")] = s
        return s

    def build_creatures(self):
        RIGHT = 0x10
        crew = "Охранник дома Решерек: кожаный доспех, обсидиановый меч, взгляд поверх рабов."
        self.creature("ath_crew_hold", "nw_guard.utc", "ATH_CREW_HOLD", "Охранник трюма",
                      desc=crew, faction=self.f_resherek, conversation="ath_dlg_guard")
        self.creature("ath_crew_guard", "nw_guard.utc", "ATH_CREW_GUARD", "Охранник каравана",
                      desc=crew, faction=self.f_resherek)
        self.creature("ath_crew_psion", "nw_gypsy002.utc", "ATH_CREW_PSION", "Псионик",
                      desc="Худой человек в выбеленном плаще. Глаза не моргают.",
                      faction=self.f_resherek, conversation="ath_dlg_psion")
        elf = "Эльф Джура-Дай: лёгкая одежда, костяной меч, факел, обветренное лицо."
        self.creature("ath_elf_raider", "nw_drowfight001.utc", "ATH_ELF", "Эльф Джура-Дай",
                      desc=elf, faction=self.f_juradai, appearance=245, gender=0, race=1)
        self.creature("ath_elf_chief", "nw_drowfight005.utc", "ATH_ELF_CHIEF", "Вождь Джура-Дай",
                      desc="Высокий эльф в кожаном нагруднике из панциря канка. "
                           "На поясе стальной кинжал — на Атхасе это целое состояние.",
                      faction=self.f_juradai, conversation="ath_dlg_chief",
                      appearance=246, gender=0, race=1)
        thirsty = "Охранник каравана. Губы потрескались, на поясе пустая фляга."
        self.creature("ath_thirsty", "nw_bandit001.utc", "ATH_THIRSTY", "Жаждущий охранник",
                      desc=thirsty, faction=FACTION_COMMONER, equip={RIGHT: "ath_wpn_thirsty"})
        self.creature("ath_thirsty_ldr", "nw_bandit003.utc", "ATH_THIRSTY_LDR",
                      "Главарь охранников", desc=thirsty, faction=FACTION_COMMONER,
                      conversation="ath_dlg_thirsty", equip={RIGHT: "ath_wpn_thirsty"})

    # ---- placeables / doors ----------------------------------------------
    def placeable(self, resref, base, tag, name, desc="", useable=0, static=0, plot=0,
                  inventory=0, scripts=None, hp=None, register=True):
        s = self.clone(base)
        fset(s, "TemplateResRef", RESREF, resref)
        fset(s, "Tag", CEXOSTRING, tag)
        fset(s, "LocName", CEXOLOCSTRING, loc(name))
        fset(s, "Description", CEXOLOCSTRING, loc(desc))
        fset(s, "Useable", BYTE, useable)
        fset(s, "Static", BYTE, static)
        fset(s, "Plot", BYTE, plot)
        fset(s, "HasInventory", BYTE, inventory)
        for ev in ("OnOpen", "OnDeath", "OnUsed", "OnClosed", "OnInvDisturbed",
                   "OnHeartbeat", "OnDamaged"):
            fset(s, ev, RESREF, "")
        for ev, script in (scripts or {}).items():
            fset(s, ev, RESREF, script)
        if hp is not None:
            fset(s, "HP", SHORT, hp)
            fset(s, "CurrentHP", SHORT, hp)
        fset(s, "Comment", CEXOSTRING, "Атхас")
        if register:
            self.blueprints[(resref, "utp")] = s
        return s

    def build_placeables(self):
        self.placeable("ath_bone_loop", "plc_bones.utp", "ath_bone_loop", "Костяная петля",
                       "Петля из кости великана, вбитая в стену. К ней привязана верёвка "
                       "из волос великана, а верёвка — к вашему ошейнику.",
                       useable=1, plot=1, scripts={"OnUsed": "ath_s1_loop"})
        self.placeable("ath_timiris", "tm_pl_bushlg01.utp", "ATH_TIMIRIS", "Тимирис",
                       "Колючий кустарник. Полые шипы длиной с палец.", hp=10)
        self.placeable("ath_pool", "nw_plc_puddle1.utp", "ath_pool", "Серебристый блеск",
                       "Посреди зарослей что-то блестит. Похоже на воду.",
                       useable=1, plot=1, scripts={"OnUsed": "ath_s6_pool"})
        self.placeable("ath_wreck", "plc_ruinwagon.utp", "ath_wreck", "Остов повозки",
                       "Обгоревшие рёбра огромной повозки.", static=0, plot=1)
        self.placeable("ath_wreck_cache", "plc_rubble.utp", "ath_wreck_cache",
                       "Обломки повозки", "Угли, оплавленный песок и осколки.",
                       useable=1, plot=1, inventory=1)

    def door(self, base, tag, name, locked=0, plot=0, linked_to="", link_flags=0):
        s = self.clone(base)
        fset(s, "Tag", CEXOSTRING, tag)
        fset(s, "LocName", CEXOLOCSTRING, loc(name))
        fset(s, "Locked", BYTE, locked)
        fset(s, "Lockable", BYTE, 1 if locked else 0)
        fset(s, "KeyRequired", BYTE, 1 if locked else 0)
        fset(s, "OpenLockDC", BYTE, 100 if locked else 0)
        fset(s, "Plot", BYTE, plot)
        fset(s, "LinkedTo", CEXOSTRING, linked_to)
        fset(s, "LinkedToFlags", BYTE, link_flags)
        fset(s, "OnDeath", RESREF, "")
        return s

    # ---- GIT instances ----------------------------------------------------
    def git(self, area):
        if area not in self.gits:
            g = self.read(area, "git")
            for lbl in ("Creature List", "Door List", "Encounter List", "List",
                        "Placeable List", "SoundList", "StoreList", "TriggerList",
                        "WaypointList"):
                fset(g, lbl, LIST, [])
            self.gits[area] = g
        return self.gits[area]

    def add(self, area, lst, obj):
        self.git(area).get(lst).append(obj)
        return obj

    def put_creature(self, area, resref, x, y, deg=90):
        s = copy.deepcopy(self.blueprints[(resref, "utc")])
        fdel(s, "PaletteID", "Comment")
        s.type = 4
        fx, fy = facing(deg)
        for lbl, v in (("XPosition", x), ("YPosition", y), ("ZPosition", 0.0),
                       ("XOrientation", fx), ("YOrientation", fy)):
            fset(s, lbl, FLOAT, v)
        return self.add(area, "Creature List", s)

    def put_placeable(self, area, src, x, y, deg=0, tag=None, name=None, items=(), **kw):
        if isinstance(src, Struct):
            s = copy.deepcopy(src)
        elif (src, "utp") in self.blueprints:
            s = copy.deepcopy(self.blueprints[(src, "utp")])
        else:
            s = self.placeable(src.split(".")[0], src, tag or src, name or "", register=False, **kw)
        if tag:
            fset(s, "Tag", CEXOSTRING, tag)
        if name:
            fset(s, "LocName", CEXOLOCSTRING, loc(name))
        fdel(s, "PaletteID", "Comment")
        s.type = 9
        fset(s, "X", FLOAT, x)
        fset(s, "Y", FLOAT, y)
        fset(s, "Z", FLOAT, 0.0)
        fset(s, "Bearing", FLOAT, math.radians(deg))
        fset(s, "BodyBag", BYTE, 0)
        fset(s, "ItemList", LIST, [self.item_instance(r, n, i) for i, (r, n) in enumerate(items)])
        if items:
            fset(s, "HasInventory", BYTE, 1)
            fset(s, "Useable", BYTE, 1)
        return self.add(area, "Placeable List", s)

    def put_door(self, area, door, x, y, deg=0):
        s = copy.deepcopy(door)
        fdel(s, "PaletteID", "Comment")
        s.type = 8
        fset(s, "X", FLOAT, x)
        fset(s, "Y", FLOAT, y)
        fset(s, "Z", FLOAT, 0.0)
        fset(s, "Bearing", FLOAT, math.radians(deg))
        return self.add(area, "Door List", s)

    def put_waypoint(self, area, tag, x, y, name=None, deg=90):
        fx, fy = facing(deg)
        s = Struct(5, [
            ("Appearance", BYTE, 1), ("Description", CEXOLOCSTRING, LocString()),
            ("HasMapNote", BYTE, 0), ("LinkedTo", CEXOSTRING, ""),
            ("LocalizedName", CEXOLOCSTRING, loc(name or tag)),
            ("MapNote", CEXOLOCSTRING, LocString()), ("MapNoteEnabled", BYTE, 0),
            ("Tag", CEXOSTRING, tag), ("TemplateResRef", RESREF, "nw_waypoint001"),
            ("XPosition", FLOAT, x), ("YPosition", FLOAT, y), ("ZPosition", FLOAT, 0.0),
            ("XOrientation", FLOAT, fx), ("YOrientation", FLOAT, fy),
        ])
        return self.add(area, "WaypointList", s)

    def put_trigger(self, area, tag, name, x, y, w, h, on_enter="", on_exit="",
                    linked_to=""):
        hw, hh = w / 2.0, h / 2.0
        pts = [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)]
        geometry = [Struct(3, [("PointX", FLOAT, px), ("PointY", FLOAT, py),
                               ("PointZ", FLOAT, 0.025)]) for px, py in pts]
        transition = bool(linked_to)
        s = Struct(1, [
            ("AutoRemoveKey", BYTE, 0), ("Cursor", BYTE, 1 if transition else 0),
            ("DisarmDC", BYTE, 0), ("Faction", DWORD, 1), ("HighlightHeight", FLOAT, 0.0),
            ("KeyName", CEXOSTRING, ""), ("LinkedTo", CEXOSTRING, linked_to),
            ("LinkedToFlags", BYTE, 2 if transition else 0), ("LoadScreenID", WORD, 0),
            ("LocalizedName", CEXOLOCSTRING, loc(name)),
            ("OnClick", RESREF, ""), ("OnDisarm", RESREF, ""), ("OnTrapTriggered", RESREF, ""),
            ("PortraitId", WORD, 0), ("ScriptHeartbeat", RESREF, ""),
            ("ScriptOnEnter", RESREF, on_enter), ("ScriptOnExit", RESREF, on_exit),
            ("ScriptUserDefine", RESREF, ""), ("Tag", CEXOSTRING, tag),
            ("TemplateResRef", RESREF, "newtransition" if transition else "newgeneric"),
            ("TrapDetectable", BYTE, 1), ("TrapDetectDC", BYTE, 0), ("TrapDisarmable", BYTE, 1),
            ("TrapFlag", BYTE, 0), ("TrapOneShot", BYTE, 1), ("TrapType", BYTE, 0),
            ("Type", INT, 1 if transition else 0),
            ("XPosition", FLOAT, x), ("YPosition", FLOAT, y), ("ZPosition", FLOAT, 0.0),
            ("XOrientation", FLOAT, 0.0), ("YOrientation", FLOAT, 0.0),
            ("ZOrientation", FLOAT, 0.0), ("Geometry", LIST, geometry),
        ])
        return self.add(area, "TriggerList", s)

    # ---- areas -------------------------------------------------------------
    def build_wagon(self):
        a = AREA_WAGON
        # Трюм F — западный край повозки; остальное — палуба и каюты A–E.
        self.put_waypoint(a, "ATH_WP_CHAIN", 15.0, 15.0, "Привязь", deg=0)
        self.put_trigger(a, "ATH_TRG_CHAIN", "Привязь", 15.0, 15.0, 6.0, 6.0,
                         on_exit="ath_chain_exit")
        self.put_placeable(a, "ath_bone_loop", 12.5, 15.0, deg=0)
        hold_door = self.door("nw_door_strong.utd", "ATH_HOLD_DOOR", "Дверь трюма",
                              locked=1, plot=1)
        self.put_door(a, hold_door, 21.0, 12.0, deg=90)
        self.put_door(a, hold_door, 21.0, 32.0, deg=90)
        wagon_door = self.door("nw_door_normal.utd", "ATH_WAGON_DOOR", "Дверь наружу",
                               linked_to="ATH_WP_L2_ARRIVE", link_flags=2)
        self.put_door(a, wagon_door, 71.0, 25.0, deg=90)

        self.put_creature(a, "ath_crew_hold", 25.0, 15.0, deg=180)
        for x, y in ((45.0, 15.0), (55.0, 15.0), (46.0, 35.0), (55.0, 33.0)):
            self.put_creature(a, "ath_crew_guard", x, y, deg=0)
        self.put_creature(a, "ath_crew_psion", 35.0, 35.0, deg=270)

        self.put_waypoint(a, "ATH_WP_LIGHTNING", 45.0, 25.0, "Удар молнии")
        self.put_waypoint(a, "ATH_WP_DECK", 55.0, 25.0, "Боевой пост")
        self.put_waypoint(a, "ATH_WP_BOARD", 65.0, 15.0, "Абордаж")
        self.put_placeable(a, "plc_invisobj.utp", 45.0, 41.0, tag="ATH_VOICE", name="Голоса снаружи")

        # Комнаты A–E.
        self.put_placeable(a, "plc_box1.utp", 22.0, 38.0, tag="ATH_ROOM_A",
                           name="Ящик с оружием", items=[("ath_obs_shard", 1), ("ath_obs_shard", 1)])
        self.put_placeable(a, "plc_barrel.utp", 31.0, 41.0, tag="ATH_ROOM_B",
                           name="Бочка для еды")
        self.put_placeable(a, "plc_chest1.utp", 39.0, 38.0, tag="ATH_ROOM_C",
                           name="Сундук псионика", items=[("nw_it_gold001", 25)])
        safe = self.put_placeable(a, "plc_chest4.utp", 58.0, 38.0, tag="ATH_ROOM_D",
                                  name="Сейф капитана Веома",
                                  items=[("nw_it_gold001", 25), ("ath_map", 1)])
        for lbl, ft, v in (("TrapFlag", BYTE, 1), ("TrapType", BYTE, TRAP_MINOR_GAS),
                           ("TrapDetectable", BYTE, 1), ("TrapDetectDC", BYTE, 15),
                           ("TrapDisarmable", BYTE, 1), ("DisarmDC", BYTE, 15),
                           ("TrapOneShot", BYTE, 1)):
            fset(safe, lbl, ft, v)
        self.put_placeable(a, "plc_barrel.utp", 66.0, 38.0, tag="ATH_ROOM_E",
                           name="Бочка с водой", items=[("ath_water_q", 10), ("ath_water_q", 10)])

    def build_desert(self):
        a = AREA_DESERT
        cx, cy = 40.0, 45.0     # повозка
        self.put_waypoint(a, "ATH_WP_L2_ARRIVE", 40.0, 37.0, "У двери повозки", deg=270)
        part = self.placeable("tm_pl_caravan2", "tm_pl_caravan2.utp", "ATH_WAGON_PART",
                              "Повозка Решерека", plot=1, register=False)
        self.put_placeable(a, part, cx, cy, deg=0)
        for src, x, y in (("plc_fullwagon.utp", cx + 8.0, cy + 3.0),
                          ("plc_emptywagon.utp", cx - 8.0, cy + 3.0)):
            self.put_placeable(a, src, x, y, deg=0, tag="ATH_WAGON_PART",
                               name="Повозка Решерека", plot=1)
        for i, (dx, dy) in enumerate(((-5, -2), (0, -3), (5, -2), (-8, 4), (8, 4),
                                      (-3, 5), (3, 5))):
            self.put_waypoint(a, "ATH_WP_FIRE", cx + dx, cy + dy, f"Огонь {i + 1}")
        self.put_waypoint(a, "ATH_WP_WRECK", cx, cy, "Остов")
        self.put_waypoint(a, "ATH_WP_WRECK", cx + 8.0, cy + 3.0, "Остов")
        self.put_waypoint(a, "ATH_WP_CACHE", cx - 4.0, cy - 5.0, "Тайник")
        self.put_waypoint(a, "ATH_WP_ELF_EXIT", 4.0, 40.0, "Уход эльфов")
        self.put_waypoint(a, "ATH_WP_GUARDS", 70.0, 52.0, "Жаждущие охранники")
        self.put_waypoint(a, "ATH_WP_GUARDS_EXIT", 76.0, 76.0, "Охранники уходят")

        self.put_creature(a, "ath_elf_chief", 40.0, 29.0, deg=90)
        n = 20
        for i in range(n):
            ang = 2 * math.pi * i / n
            r = 15.0 + (i % 3) * 2.5
            x, y = cx + r * math.cos(ang), cy - 2.0 + r * math.sin(ang)
            x, y = min(max(x, 22.0), 62.0), min(max(y, 22.0), 62.0)
            self.put_creature(a, "ath_elf_raider", x, y, deg=math.degrees(ang) + 180)

        self.put_trigger(a, "ATH_TRG_WRECK", "Пепелище", cx, cy, 24.0, 14.0,
                         on_enter="ath_s4_wreck")
        self.put_trigger(a, "ATH_TRG_EXIT_NE", "Выход на северо-восток", 66.0, 66.0, 8.0, 8.0,
                         on_enter="ath_s4_exit")
        self.put_trigger(a, "ATH_TRG_EXIT_SW", "Выход на юго-запад", 14.0, 14.0, 8.0, 8.0,
                         on_enter="ath_s4_exit")
        self.put_trigger(a, "ATH_TRG_SHADE", "Тень скал", 24.0, 57.0, 8.0, 6.0,
                         on_enter="ath_shade_in", on_exit="ath_shade_out")
        self.put_trigger(a, "ATH_TRG_SHADE", "Тень скал", 57.0, 24.0, 6.0, 8.0,
                         on_enter="ath_shade_in", on_exit="ath_shade_out")
        self.put_trigger(a, "ATH_TRG_URIK", "Дорога на Урик", 75.0, 75.0, 8.0, 8.0,
                         on_enter="ath_urik_road")
        self.put_trigger(a, "ATH_TRG_TO_L3", "На юго-запад", 4.0, 4.0, 6.0, 6.0,
                         linked_to="ATH_WP_L3_ARRIVE")

    def build_night(self):
        a = AREA_NIGHT
        self.put_waypoint(a, "ATH_WP_L3_ARRIVE", 105.0, 105.0, "С севера-востока", deg=225)
        cx, cy, r = 60.0, 60.0, 9.0
        # Кольцо тимириса с проходом на востоке; вдоль прохода кусты образуют тоннель.
        for i in range(16):
            ang = 2 * math.pi * i / 16
            if i in (0, 15, 1):
                continue
            self.put_placeable(a, "ath_timiris", cx + r * math.cos(ang), cy + r * math.sin(ang),
                               deg=math.degrees(ang))
        for x in (cx + 10.5, cx + 13.0):
            for y in (cy - 2.2, cy + 2.2):
                self.put_placeable(a, "ath_timiris", x, y, deg=0)
        self.put_trigger(a, "ATH_TRG_TUNNEL", "Тоннель в зарослях", cx + 9.5, cy, 3.0, 3.0,
                         on_enter="ath_s6_tunnel")
        self.put_placeable(a, "ath_pool", cx, cy, deg=0)
        self.put_trigger(a, "ATH_TRG_END", "Край пустошей", 8.0, 8.0, 12.0, 12.0,
                         on_enter="ath_end")

    # ---- dialogs -------------------------------------------------------------
    def dialog(self, resref, tree, abort=""):
        entries, replies = [], []

        def node(text, script, kind):
            s = Struct(0, [("Animation", DWORD, 0), ("AnimLoop", BYTE, 1),
                           ("Comment", CEXOSTRING, ""), ("Delay", DWORD, 0xFFFFFFFF),
                           ("Quest", CEXOSTRING, ""), ("Script", RESREF, script or ""),
                           ("Sound", RESREF, ""), ("Text", CEXOLOCSTRING, loc(text))])
            if kind == "npc":
                s.add("Speaker", CEXOSTRING, "")
                s.add("RepliesList", LIST, [])
            else:
                s.add("EntriesList", LIST, [])
            return s

        def link(idx, cond="", child=0):
            return Struct(0, [("Index", DWORD, idx), ("Active", RESREF, cond),
                              ("IsChild", BYTE, child)])

        named = {}

        def walk(n, kind):
            if "ref" in n:                      # ссылка на уже созданный узел
                return named[n["ref"]], True
            lst = entries if kind == "npc" else replies
            s = node(n["text"], n.get("script"), kind)
            idx = len(lst)
            lst.append(s)
            if "name" in n:
                named[n["name"]] = idx
            child_kind = "pc" if kind == "npc" else "npc"
            for c in n.get("children", []):
                cidx, is_ref = walk(c, child_kind)
                s.get("RepliesList" if kind == "npc" else "EntriesList").append(
                    link(cidx, c.get("cond", ""), 1 if is_ref else 0))
            return idx, False

        starts = []
        for root in tree:
            idx, _ = walk(root, "npc")
            starts.append(Struct(0, [("Index", DWORD, idx), ("Active", RESREF, root.get("cond", ""))]))
        words = sum(len(e.get("Text").strings[0].split()) for e in entries + replies)
        s = Struct(fields=[
            ("DelayEntry", DWORD, 0), ("DelayReply", DWORD, 0), ("NumWords", DWORD, words),
            ("EndConversation", RESREF, ""), ("EndConverAbort", RESREF, abort),
            ("PreventZoomIn", BYTE, 0), ("EntryList", LIST, entries),
            ("ReplyList", LIST, replies), ("StartingList", LIST, starts)])
        self.blueprints[(resref, "dlg")] = s

    def build_dialogs(self):
        self.dialog("ath_dlg_guard", [{
            "text": "Жри молча и не пялься на меня.",
            "children": [
                {"text": "Куда нас везут?", "children": [{
                    "text": "В Тир. Дом Решерек купил вас в Урике задёшево. Продадут дорого — "
                            "на зиккурат короля. Там и сдохнете."}]},
                {"text": "Воды…", "children": [{"text": "Кварта вечером. Как всегда."}]},
            ]}])

        self.dialog("ath_dlg_psion", [{
            "text": "Слышишь? Эльфы. Защищай повозку — и уйдёшь отсюда свободным.",
            "children": [
                {"text": "Согласен.", "script": "ath_psion_agree"},
                {"text": "А если нет?", "script": "ath_psion_refuse", "children": [{
                    "text": "Тогда ты будешь драться всё равно. Только без своей воли."}]},
                {"text": "Попробуй заставь.", "script": "ath_psion_resist"},
            ]}])

        leave = {"text": "Я ухожу.", "script": "ath_confiscate", "name": "leave"}
        attack = {"text": "Вода и оружие — моё.", "script": "ath_chief_attack", "name": "attack"}
        back = [{"ref": "leave"}, {"ref": "attack"}]
        self.dialog("ath_dlg_chief", [{
            "text": "Повозка теперь принадлежит Джура-Дай. Бери два оружия и две кварты воды. "
                    "Остальное оставь — и уходи, пока мы её не подожгли.",
            "children": [
                leave,
                attack,
                {"text": "Помогите нам дойти до города.", "children": [{
                    "text": "Вы не наши. Пустыня решит, кто из вас чего стоит.",
                    "children": back}]},
                {"text": "Почему вы напали?", "cond": "ath_c_elf", "children": [{
                    "text": "Король Урика угоняет наших детей в рабство. Мы будем жечь его "
                            "караваны, пока он не перестанет.", "children": back}]},
                {"text": "Возьмите меня с собой.", "cond": "ath_c_elf", "children": [{
                    "text": "Ты был рабом в Урике. Сначала докажи, что ты эльф, а не раб.",
                    "children": back}]},
            ]}], abort="ath_confiscate")

        self.dialog("ath_dlg_thirsty", [{
            "text": "Стоять. Вода у тебя? Давай сюда.",
            "children": [
                {"text": "Держи.", "script": "ath_thirsty_give", "children": [{
                    "text": "Умный раб. Всё равно в Урике тебя снова закуют."}]},
                {"text": "[Убеждение] Половину.", "script": "ath_thirsty_half"},
                {"text": "[Запугивание] Только подойди.", "script": "ath_thirst_scare"},
                {"text": "[Блеф] В Урике вас самих в цепи закуют за потерю груза.",
                 "script": "ath_thirst_bluff"},
                {"text": "[Атаковать]", "script": "ath_thirst_fight"},
            ]}], abort="ath_thirst_fight")

    # ---- journal, factions, module -----------------------------------------
    def build_journal(self):
        texts = [
            "Я раб в трюме повозки торгового дома Решерек. Её везут из Урика в Тир, на строительство зиккурата.",
            "На караван напали эльфы. Охрана забыла о рабах — сейчас или никогда.",
            "Эльфы Джура-Дай забирают повозку. Мне оставили немного воды и велели уходить.",
            "Охранники каравана тоже выжили, и им нужна вода — любой ценой.",
            "Иду на юго-запад. Днём пекло, ночью идти легче: воды нужно вдвое меньше.",
            "Серебряный блеск в колючих зарослях оказался ловушкой.",
            "Я пережил первую ночь в пустыне. (Конец среза.)",
        ]
        entries = [Struct(0, [("ID", DWORD, i + 1), ("Text", CEXOLOCSTRING, loc(t)),
                              ("End", WORD, 1 if i == len(texts) - 1 else 0)])
                   for i, t in enumerate(texts)]
        quest = Struct(0, [("Name", CEXOLOCSTRING, loc("Выжить")), ("Tag", CEXOSTRING, "ath_survive"),
                           ("Priority", DWORD, 1), ("XP", DWORD, 0), ("Comment", CEXOSTRING, ""),
                           ("Picture", WORD, 0xFFFF), ("EntryList", LIST, entries)])
        self.blueprints[("module", "jrl")] = Struct(fields=[("Categories", LIST, [quest])])

    def build_factions(self):
        fac = self.read("repute", "fac")
        names = [f.get("FactionName") for f in fac.get("FactionList")]
        new = ["Решерек", "Джура-Дай"]
        base_count = len(names)
        for n in new:
            fac.get("FactionList").append(Struct(len(names), [
                ("FactionParentID", DWORD, 0xFFFFFFFF), ("FactionName", CEXOSTRING, n),
                ("FactionGlobal", WORD, 0)]))
            names.append(n)
        self.f_resherek, self.f_juradai = base_count, base_count + 1

        def rep(who, towards):
            if who == towards:
                return 100
            if who == FACTION_HOSTILE or towards == FACTION_HOSTILE:
                return 0
            return 50
        reps = fac.get("RepList")
        for towards in range(len(names)):
            for who in range(1, len(names)):
                if towards >= base_count or who >= base_count:
                    reps.append(Struct(len(reps), [("FactionID1", DWORD, towards),
                                                   ("FactionID2", DWORD, who),
                                                   ("FactionRep", DWORD, rep(who, towards))]))
        self.blueprints[("repute", "fac")] = fac

    def build_ifo(self):
        ifo = self.read("module", "ifo")
        fset(ifo, "Mod_Name", CEXOLOCSTRING, loc("Атхас: Немного знания"))
        fset(ifo, "Mod_Description", CEXOLOCSTRING, loc(
            "Dark Sun, «A Little Knowledge» (TSR, 1991): вертикальный срез, сцены 1–6. "
            "Один герой, 3-й уровень."))
        fset(ifo, "Mod_Tag", CEXOSTRING, "ATHAS_ALK")
        fset(ifo, "Mod_Entry_Area", RESREF, AREA_WAGON)
        for lbl, v in (("Mod_Entry_X", 15.0), ("Mod_Entry_Y", 15.0), ("Mod_Entry_Z", 0.0),
                       ("Mod_Entry_Dir_X", 1.0), ("Mod_Entry_Dir_Y", 0.0)):
            fset(ifo, lbl, FLOAT, v)
        fset(ifo, "Mod_Area_list", LIST, [Struct(6, [("Area_Name", RESREF, r)])
                                          for r in (AREA_WAGON, AREA_DESERT, AREA_NIGHT)])
        fset(ifo, "Mod_StartHour", BYTE, 9)
        fset(ifo, "Mod_DawnHour", BYTE, 6)
        fset(ifo, "Mod_DuskHour", BYTE, 19)
        scripts = {
            "Mod_OnModLoad": "ath_mod_load", "Mod_OnClientEntr": "ath_start",
            "Mod_OnHeartbeat": "ath_mod_hb", "Mod_OnPlrRest": "ath_rest",
            "Mod_OnActvtItem": "x2_mod_def_act", "Mod_OnAcquirItem": "x2_mod_def_aqu",
            "Mod_OnUnAqreItem": "x2_mod_def_unaqu", "Mod_OnPlrEqItm": "x2_mod_def_equ",
            "Mod_OnPlrUnEqItm": "x2_mod_def_unequ", "Mod_OnPlrDeath": "nw_o0_death",
            "Mod_OnPlrDying": "nw_o0_dying", "Mod_OnSpawnBtnDn": "nw_o0_respawn",
        }
        for lbl, s in scripts.items():
            fset(ifo, lbl, RESREF, s)
        fset(ifo, "Mod_ID", VOID, uuid.uuid4().bytes)
        self.blueprints[("module", "ifo")] = ifo

    def build_areas(self):
        settings = {
            AREA_WAGON: dict(tag="ATH_AREA_WAGON", name="Повозка Решерека", on_enter="",
                             night=0, cycle=0),
            AREA_DESERT: dict(tag="ATH_AREA_DESERT", name="Пески у повозки",
                              on_enter="ath_l2_enter", night=0, cycle=1),
            AREA_NIGHT: dict(tag="ATH_AREA_NIGHT", name="Песчаные пустоши",
                             on_enter="ath_l3_enter", night=1, cycle=0),
        }
        for area, cfg in settings.items():
            are = self.read(area, "are")
            fset(are, "Tag", CEXOSTRING, cfg["tag"])
            fset(are, "Name", CEXOLOCSTRING, loc(cfg["name"]))
            fset(are, "OnEnter", RESREF, cfg["on_enter"])
            fset(are, "IsNight", BYTE, cfg["night"])
            fset(are, "DayNightCycle", BYTE, cfg["cycle"])
            if area == AREA_DESERT:
                fset(are, "SunDiffuseColor", DWORD, 0x0060B0FF)   # 0x00BBGGRR: белёсо-оранжевый
                fset(are, "SunAmbientColor", DWORD, 0x00405A80)
                fset(are, "SunFogColor", DWORD, 0x0070A0D0)
                fset(are, "SunFogAmount", BYTE, 6)
            if area == AREA_NIGHT:
                fset(are, "MoonDiffuseColor", DWORD, 0x00A08850)  # сине-зелёный свет двух лун
                fset(are, "MoonAmbientColor", DWORD, 0x00503C20)
                fset(are, "MoonFogColor", DWORD, 0x00302010)
                fset(are, "MoonFogAmount", BYTE, 8)
            self.blueprints[(area, "are")] = are

    # ---- scripts ---------------------------------------------------------------
    def build_scripts(self):
        out = os.path.join(self.work, "nss")
        os.makedirs(out, exist_ok=True)
        for f in os.listdir(out):
            os.remove(os.path.join(out, f))
        names = sorted(f[:-4] for f in os.listdir(SCRIPTS_DIR) if f.endswith(".nss"))
        for n in names:
            if len(n) > 16:
                raise SystemExit(f"Имя скрипта длиннее 16 символов: {n}")
            text = open(os.path.join(SCRIPTS_DIR, n + ".nss"), encoding="utf-8").read()
            data = text.encode("cp1251", errors="replace")   # как nwn-mcp: «?» вместо символа
            if data.count(b"?") != text.count("?"):
                print(f"  {n}.nss: символы вне cp1251 заменены на «?»")
            open(os.path.join(out, n + ".nss"), "wb").write(data)
        comp = os.path.join(self.tools, "nwn_script_comp.exe")
        mains = [n + ".nss" for n in names if not n.startswith("ath_inc_")]
        incs = [n + ".nss" for n in names if n.startswith("ath_inc_")]
        common = [comp, "--root", self.game, "--nwn-encoding", "windows-1251", "-y"]
        r1 = subprocess.run(common + ["-c"] + mains, cwd=out, capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
        r2 = subprocess.run(common + ["--no-require-entry-point", "-s", "-c"] + incs, cwd=out,
                            capture_output=True, text=True, encoding="utf-8", errors="replace")
        log = (r1.stdout + r1.stderr + r2.stdout + r2.stderr).strip()
        failed = [m for m in mains if not os.path.exists(os.path.join(out, m[:-4] + ".ncs"))]
        if failed or r2.returncode:
            print(log)
            raise SystemExit("Ошибки компиляции: " + ", ".join(failed or incs))
        for n in names:
            self.res[(n, "nss")] = open(os.path.join(out, n + ".nss"), "rb").read()
            ncs = os.path.join(out, n + ".ncs")
            if os.path.exists(ncs):
                self.res[(n, "ncs")] = open(ncs, "rb").read()
        return len(mains), len(incs)

    # ---- GIC + output -------------------------------------------------------
    def gic_for(self, git):
        s = Struct()
        for lbl in ("Creature List", "Door List", "Encounter List", "List", "Placeable List",
                    "SoundList", "StoreList", "TriggerList", "WaypointList"):
            s.add(lbl, LIST, [Struct(o.type, [("Comment", CEXOSTRING, "")]) for o in git.get(lbl)])
        return s

    def build(self, out_path):
        for key in [k for k in self.res if k[0] in ("_start", "ath_enc_test")]:
            del self.res[key]
        self.build_factions()
        self.build_items()
        self.build_creatures()
        self.build_placeables()
        self.build_wagon()
        self.build_desert()
        self.build_night()
        self.build_dialogs()
        self.build_journal()
        self.build_ifo()
        self.build_areas()
        n_main, n_inc = self.build_scripts()
        for area, git in self.gits.items():
            self.blueprints[(area, "git")] = git
            self.blueprints[(area, "gic")] = self.gic_for(git)
        for (resref, ext), s in self.blueprints.items():
            self.put(resref, ext, s)
        order = sorted(self.res.items(), key=lambda kv: (kv[0][1], kv[0][0]))
        data = write_erf([(r, e, d) for (r, e), d in order], "MOD ")
        open(out_path, "wb").write(data)
        counts = {a: {l: len(g.get(l)) for l in ("Creature List", "Placeable List", "Door List",
                                                 "TriggerList", "WaypointList")}
                  for a, g in self.gits.items()}
        print(f"Записан {out_path}: {len(order)} ресурсов, {len(data)} байт; "
              f"скриптов {n_main} + include {n_inc}")
        for a, c in counts.items():
            print(f"  {a}: " + ", ".join(f"{k} {v}" for k, v in c.items()))


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--base", required=True, help="модуль с тайлами локаций")
    p.add_argument("-o", "--output", required=True)
    p.add_argument("--game", default=r"C:/Program Files (x86)/Steam/steamapps/common/Neverwinter Nights")
    p.add_argument("--tools", default=r"C:/tools/nwn-mcp")
    p.add_argument("--work", default=os.path.join(tempfile.gettempdir(), "athas-build"))
    a = p.parse_args()
    Builder(a.base, a.game, a.tools, a.work).build(a.output)


if __name__ == "__main__":
    main()
