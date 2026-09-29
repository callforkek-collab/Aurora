#!/usr/bin/env python3
"""Build a tiny NWN 1 module: a starting cave with a friendly dragon.

The dragon greets the player when they talk to it (click on it).

Usage:
    python3 build_dragon_cave.py            # Russian text (cp1251) -> dist/dragoncave.mod
    python3 build_dragon_cave.py --lang en  # English text (cp1252) -> dist/dragoncave_en.mod

Copy the .mod into "Documents/Neverwinter Nights/modules" (EE) or
"NeverwinterNights/NWN/modules" (1.69) and open it in the Aurora Toolset.
"""

import argparse
import os
import uuid

from nwnmod import gff
from nwnmod.erf import write_erf
from nwnmod.gff import (BYTE, CEXOLOCSTRING, CEXOSTRING, DWORD,
                        FLOAT, INT, LIST, RESREF, SHORT, STRUCT, VOID, WORD,
                        LocString, Struct)

TEXT = {
    "ru": {
        "encoding": "cp1251",
        "module_name": "Пещера дракона",
        "module_desc": "Небольшая стартовая пещера. В её глубине живёт дракон.",
        "area_name": "Пещера дракона",
        "dragon_first": "Древний дракон",
        "dragon_desc": "Огромный красный дракон. Кажется, он настроен дружелюбно.",
        "greeting": "Привет, путник!",
        "goodbye": "До свидания.",
    },
    "en": {
        "encoding": "cp1252",
        "module_name": "Dragon Cave",
        "module_desc": "A small starting cave. A dragon lives deep inside.",
        "area_name": "Dragon Cave",
        "dragon_first": "Ancient Dragon",
        "dragon_desc": "A huge red dragon. It seems friendly enough.",
        "greeting": "Hello, traveller!",
        "goodbye": "Goodbye.",
    },
}

AREA = "dragoncave"          # area resref
DIALOG = "dragon_hello"      # dialog resref
DRAGON = "cave_dragon"       # creature blueprint resref / tag

TILESET = "tdm01"            # Mines and Caverns
AREA_W, AREA_H = 6, 6        # tiles (10 m each)

PLAYER_POS = (15.0, 15.0, 0.0)
PLAYER_DIR = (0.7071, 0.7071)    # facing north-east, toward the dragon
DRAGON_POS = (38.0, 38.0, 0.0)
DRAGON_DIR = (-0.7071, -0.7071)  # facing south-west, toward the player

# Row numbers in the stock 2da files.
APPEARANCE_RED_DRAGON = 48   # appearance.2da  (APPEARANCE_TYPE_DRAGON_RED)
RACE_DRAGON = 11             # racialtypes.2da (RACIAL_TYPE_DRAGON)
CLASS_DRAGON = 18            # classes.2da     (CLASS_TYPE_DRAGON)
FACTION_COMMONER = 2         # repute.fac      (non-hostile)
SKILL_COUNT = 28             # skills.2da rows


def loc(text):
    """Inline string for language 0 (English slot, used by all 1-byte locales)."""
    return LocString({0: text})


def empty_loc():
    return LocString()


# --------------------------------------------------------------------------
# module.ifo

def build_ifo(t):
    s = Struct()
    s.add("Mod_ID", VOID, uuid.uuid4().bytes)
    s.add("Mod_Creator_ID", INT, 2)
    s.add("Mod_Version", DWORD, 3)
    s.add("Mod_Name", CEXOLOCSTRING, loc(t["module_name"]))
    s.add("Mod_Tag", CEXOSTRING, "DRAGONCAVE")
    s.add("Mod_Description", CEXOLOCSTRING, loc(t["module_desc"]))
    s.add("Mod_IsSaveGame", BYTE, 0)
    s.add("Mod_CustomTlk", CEXOSTRING, "")
    s.add("Mod_MinGameVer", CEXOSTRING, "1.69")
    s.add("Expansion_Pack", WORD, 0)
    s.add("Mod_Hak", CEXOSTRING, "")
    s.add("Mod_HakList", LIST, [])
    s.add("Mod_StartMovie", RESREF, "")
    s.add("Mod_Entry_Area", RESREF, AREA)
    s.add("Mod_Entry_X", FLOAT, PLAYER_POS[0])
    s.add("Mod_Entry_Y", FLOAT, PLAYER_POS[1])
    s.add("Mod_Entry_Z", FLOAT, PLAYER_POS[2])
    s.add("Mod_Entry_Dir_X", FLOAT, PLAYER_DIR[0])
    s.add("Mod_Entry_Dir_Y", FLOAT, PLAYER_DIR[1])
    s.add("Mod_Area_list", LIST, [Struct(6, [("Area_Name", RESREF, AREA)])])
    s.add("Mod_DawnHour", BYTE, 6)
    s.add("Mod_DuskHour", BYTE, 18)
    s.add("Mod_MinPerHour", BYTE, 2)
    s.add("Mod_StartYear", DWORD, 1372)
    s.add("Mod_StartMonth", BYTE, 6)
    s.add("Mod_StartDay", BYTE, 1)
    s.add("Mod_StartHour", BYTE, 13)
    s.add("Mod_XPScale", BYTE, 10)
    s.add("Mod_Expan_List", LIST, [])
    s.add("Mod_CutSceneList", LIST, [])
    s.add("Mod_GVar_List", LIST, [])
    s.add("Mod_CacheNSSList", LIST, [])
    # Stock event scripts shipped with the game (same as a new toolset module).
    scripts = {
        "Mod_OnAcquirItem": "x2_mod_def_aqu",
        "Mod_OnActvtItem": "x2_mod_def_act",
        "Mod_OnClientEntr": "",
        "Mod_OnClientLeav": "",
        "Mod_OnCutsnAbort": "",
        "Mod_OnHeartbeat": "",
        "Mod_OnModLoad": "x2_mod_def_load",
        "Mod_OnModStart": "",
        "Mod_OnPlrDeath": "nw_o0_death",
        "Mod_OnPlrDying": "nw_o0_dying",
        "Mod_OnPlrEqItm": "x2_mod_def_equ",
        "Mod_OnPlrLvlUp": "",
        "Mod_OnPlrRest": "x2_mod_def_rest",
        "Mod_OnPlrUnEqItm": "x2_mod_def_unequ",
        "Mod_OnSpawnBtnDn": "nw_o0_respawn",
        "Mod_OnUnAqreItem": "x2_mod_def_unaqu",
        "Mod_OnUsrDefined": "",
    }
    for label, script in scripts.items():
        s.add(label, RESREF, script)
    return s


# --------------------------------------------------------------------------
# repute.fac - the five standard factions

def build_fac():
    names = ["PC", "Hostile", "Commoner", "Merchant", "Defender"]
    factions = []
    for i, name in enumerate(names):
        factions.append(Struct(i, [
            ("FactionParentID", DWORD, 0xFFFFFFFF),
            ("FactionName", CEXOSTRING, name),
            ("FactionGlobal", WORD, 0 if i == 0 else 1),
        ]))

    def rep(who, towards):
        # How faction `who` feels about faction `towards`.
        if who == towards:
            return 100
        if who == 1 or towards == 1:
            return 0      # Hostile hates everyone and is hated by everyone
        if towards == 0:
            return 50     # neutral toward players
        return 100

    reps = []
    for towards in range(len(names)):
        for who in range(1, len(names)):   # the PC faction has no RepList rows
            reps.append(Struct(len(reps), [
                ("FactionID1", DWORD, towards),
                ("FactionID2", DWORD, who),
                ("FactionRep", DWORD, rep(who, towards)),
            ]))
    return Struct(fields=[("FactionList", LIST, factions),
                          ("RepList", LIST, reps)])


# --------------------------------------------------------------------------
# Area: .are (static layout), .git (instances), .gic (toolset comments)

def build_are(t):
    tiles = []
    for _ in range(AREA_W * AREA_H):
        tiles.append(Struct(1, [
            ("Tile_ID", INT, 0),
            ("Tile_Orientation", INT, 0),
            ("Tile_Height", INT, 0),
            ("Tile_MainLight1", BYTE, 0),
            ("Tile_MainLight2", BYTE, 0),
            ("Tile_SrcLight1", BYTE, 0),
            ("Tile_SrcLight2", BYTE, 0),
            ("Tile_AnimLoop1", BYTE, 1),
            ("Tile_AnimLoop2", BYTE, 1),
            ("Tile_AnimLoop3", BYTE, 1),
        ]))

    s = Struct()
    s.add("ID", INT, -1)
    s.add("Creator_ID", INT, -1)
    s.add("Version", DWORD, 1)
    s.add("Tag", CEXOSTRING, "DRAGONCAVE")
    s.add("Name", CEXOLOCSTRING, loc(t["area_name"]))
    s.add("ResRef", RESREF, AREA)
    s.add("Comments", CEXOSTRING, "")
    s.add("Expansion_List", LIST, [])
    s.add("Flags", DWORD, 0x1 | 0x2 | 0x4)   # interior | underground | natural
    s.add("Width", INT, AREA_W)
    s.add("Height", INT, AREA_H)
    s.add("Tileset", RESREF, TILESET)
    s.add("ModSpotCheck", INT, 0)
    s.add("ModListenCheck", INT, 0)
    s.add("IsNight", BYTE, 1)
    s.add("DayNightCycle", BYTE, 0)
    s.add("LightingScheme", BYTE, 0)
    s.add("ShadowOpacity", BYTE, 60)
    s.add("SkyBox", BYTE, 0)
    # Colours are 0x00BBGGRR.
    s.add("MoonAmbientColor", DWORD, 0x00404850)
    s.add("MoonDiffuseColor", DWORD, 0x00707880)
    s.add("MoonFogAmount", BYTE, 3)
    s.add("MoonFogColor", DWORD, 0x00000000)
    s.add("MoonShadows", BYTE, 0)
    s.add("SunAmbientColor", DWORD, 0x00404850)
    s.add("SunDiffuseColor", DWORD, 0x00707880)
    s.add("SunFogAmount", BYTE, 3)
    s.add("SunFogColor", DWORD, 0x00000000)
    s.add("SunShadows", BYTE, 0)
    s.add("FogClipDist", FLOAT, 45.0)
    s.add("WindPower", INT, 0)
    s.add("ChanceLightning", INT, 0)
    s.add("ChanceRain", INT, 0)
    s.add("ChanceSnow", INT, 0)
    s.add("NoRest", BYTE, 0)
    s.add("PlayerVsPlayer", BYTE, 3)   # use module/server setting
    s.add("LoadScreenID", WORD, 0)
    s.add("OnEnter", RESREF, "")
    s.add("OnExit", RESREF, "")
    s.add("OnHeartbeat", RESREF, "")
    s.add("OnUserDefined", RESREF, "")
    s.add("Tile_List", LIST, tiles)
    return s


def creature_fields(t):
    """Fields shared by the .utc blueprint and the creature instance in .git."""
    skills = [Struct(0, [("Rank", BYTE, 0)]) for _ in range(SKILL_COUNT)]
    c = [
        ("TemplateResRef", RESREF, DRAGON),
        ("Tag", CEXOSTRING, DRAGON.upper()),
        ("FirstName", CEXOLOCSTRING, loc(t["dragon_first"])),
        ("LastName", CEXOLOCSTRING, empty_loc()),
        ("Description", CEXOLOCSTRING, loc(t["dragon_desc"])),
        ("Conversation", RESREF, DIALOG),
        ("Appearance_Type", WORD, APPEARANCE_RED_DRAGON),
        ("Phenotype", INT, 0),
        ("Gender", BYTE, 0),
        ("Race", BYTE, RACE_DRAGON),
        ("Subrace", CEXOSTRING, ""),
        ("Deity", CEXOSTRING, ""),
        ("PortraitId", WORD, 0),
        ("Tail", BYTE, 0),
        ("Wings", BYTE, 0),
        ("SoundSetFile", WORD, 0),
        ("BodyBag", BYTE, 0),
        ("StartingPackage", BYTE, 0),
        ("PerceptionRange", BYTE, 11),
        ("WalkRate", INT, 7),        # creaturespeed.2da: "Default"
        ("DecayTime", DWORD, 5000),
        ("FactionID", WORD, FACTION_COMMONER),
        ("GoodEvil", BYTE, 50),
        ("LawfulChaotic", BYTE, 50),
        ("ChallengeRating", FLOAT, 10.0),
        ("CRAdjust", INT, 0),
        ("Str", BYTE, 30), ("Dex", BYTE, 10), ("Con", BYTE, 25),
        ("Int", BYTE, 18), ("Wis", BYTE, 18), ("Cha", BYTE, 18),
        ("NaturalAC", BYTE, 20),
        ("HitPoints", SHORT, 150),
        ("CurrentHitPoints", SHORT, 150),
        ("MaxHitPoints", SHORT, 150),
        ("refbonus", SHORT, 0),
        ("willbonus", SHORT, 0),
        ("fortbonus", SHORT, 0),
        ("Plot", BYTE, 1),
        ("IsImmortal", BYTE, 1),
        ("NoPermDeath", BYTE, 0),
        ("Disarmable", BYTE, 0),
        ("Lootable", BYTE, 0),
        ("Interruptable", BYTE, 1),
        ("IsPC", BYTE, 0),
        ("ClassList", LIST, [Struct(2, [("Class", INT, CLASS_DRAGON),
                                        ("ClassLevel", SHORT, 10)])]),
        ("SkillList", LIST, skills),
        ("FeatList", LIST, []),
        ("SpecAbilityList", LIST, []),
        ("Equip_ItemList", LIST, []),
        ("ItemList", LIST, []),
        # Stock default AI scripts. nw_c2_default4 (OnConversation) calls
        # BeginConversation(), which opens the dialog set in "Conversation".
        ("ScriptHeartbeat", RESREF, "nw_c2_default1"),
        ("ScriptOnNotice", RESREF, "nw_c2_default2"),
        ("ScriptEndRound", RESREF, "nw_c2_default3"),
        ("ScriptDialogue", RESREF, "nw_c2_default4"),
        ("ScriptAttacked", RESREF, "nw_c2_default5"),
        ("ScriptDamaged", RESREF, "nw_c2_default6"),
        ("ScriptDeath", RESREF, "nw_c2_default7"),
        ("ScriptDisturbed", RESREF, "nw_c2_default8"),
        ("ScriptSpawn", RESREF, "nw_c2_default9"),
        ("ScriptRested", RESREF, "nw_c2_defaulta"),
        ("ScriptSpellAt", RESREF, "nw_c2_defaultb"),
        ("ScriptOnBlocked", RESREF, "nw_c2_defaulte"),
        ("ScriptUserDefine", RESREF, "nw_c2_defaultd"),
    ]
    return c


def build_utc(t):
    s = Struct(fields=creature_fields(t))
    s.add("PaletteID", BYTE, 0)
    s.add("Comment", CEXOSTRING, "")
    return s


def build_git(t):
    dragon = Struct(4, creature_fields(t))
    dragon.add("XPosition", FLOAT, DRAGON_POS[0])
    dragon.add("YPosition", FLOAT, DRAGON_POS[1])
    dragon.add("ZPosition", FLOAT, DRAGON_POS[2])
    dragon.add("XOrientation", FLOAT, DRAGON_DIR[0])
    dragon.add("YOrientation", FLOAT, DRAGON_DIR[1])

    props = Struct(100, [
        ("AmbientSndDay", INT, 0),
        ("AmbientSndNight", INT, 0),
        ("AmbientSndDayVol", INT, 32),
        ("AmbientSndNitVol", INT, 32),
        ("EnvAudio", INT, 0),
        ("MusicBattle", INT, 0),
        ("MusicDay", INT, 0),
        ("MusicNight", INT, 0),
        ("MusicDelay", INT, 90000),
    ])
    s = Struct()
    s.add("AreaProperties", STRUCT, props)
    s.add("Creature List", LIST, [dragon])
    for label in ("Door List", "Encounter List", "List", "Placeable List",
                  "SoundList", "StoreList", "TriggerList", "WaypointList"):
        s.add(label, LIST, [])
    return s


def build_gic():
    s = Struct()
    s.add("Creature List", LIST, [Struct(4, [("Comment", CEXOSTRING, "")])])
    for label in ("Door List", "Encounter List", "List", "Placeable List",
                  "SoundList", "StoreList", "TriggerList", "WaypointList"):
        s.add(label, LIST, [])
    return s


# --------------------------------------------------------------------------
# Dialog: the dragon says hello, the player says goodbye, conversation ends.

def build_dlg(t):
    entry = Struct(0, [
        ("Speaker", CEXOSTRING, ""),
        ("AnimLoop", BYTE, 1),
        ("Animation", DWORD, 0),
        ("Comment", CEXOSTRING, ""),
        ("Delay", DWORD, 0xFFFFFFFF),
        ("Quest", CEXOSTRING, ""),
        ("Script", RESREF, ""),
        ("Sound", RESREF, ""),
        ("Text", CEXOLOCSTRING, loc(t["greeting"])),
        ("RepliesList", LIST, [Struct(0, [
            ("Index", DWORD, 0),
            ("Active", RESREF, ""),
            ("IsChild", BYTE, 0),
        ])]),
    ])
    reply = Struct(0, [
        ("AnimLoop", BYTE, 1),
        ("Animation", DWORD, 0),
        ("Comment", CEXOSTRING, ""),
        ("Delay", DWORD, 0xFFFFFFFF),
        ("Quest", CEXOSTRING, ""),
        ("Script", RESREF, ""),
        ("Sound", RESREF, ""),
        ("Text", CEXOLOCSTRING, loc(t["goodbye"])),
        ("EntriesList", LIST, []),
    ])
    s = Struct()
    s.add("DelayEntry", DWORD, 0)
    s.add("DelayReply", DWORD, 0)
    s.add("NumWords", DWORD, len((t["greeting"] + " " + t["goodbye"]).split()))
    s.add("EndConversation", RESREF, "")
    s.add("EndConverAbort", RESREF, "")
    s.add("PreventZoomIn", BYTE, 0)
    s.add("EntryList", LIST, [entry])
    s.add("ReplyList", LIST, [reply])
    s.add("StartingList", LIST, [Struct(0, [("Index", DWORD, 0),
                                            ("Active", RESREF, "")])])
    return s


# --------------------------------------------------------------------------

def build_module(lang):
    t = TEXT[lang]
    gff.ENCODING = t["encoding"]
    resources = [
        ("module", "ifo", gff.write_gff(build_ifo(t), "IFO ")),
        ("repute", "fac", gff.write_gff(build_fac(), "FAC ")),
        (AREA, "are", gff.write_gff(build_are(t), "ARE ")),
        (AREA, "git", gff.write_gff(build_git(t), "GIT ")),
        (AREA, "gic", gff.write_gff(build_gic(), "GIC ")),
        (DRAGON, "utc", gff.write_gff(build_utc(t), "UTC ")),
        (DIALOG, "dlg", gff.write_gff(build_dlg(t), "DLG ")),
    ]
    return write_erf(resources, "MOD ")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--lang", choices=sorted(TEXT), default="ru")
    parser.add_argument("-o", "--output")
    args = parser.parse_args()

    out = args.output or os.path.join(
        "dist", "dragoncave.mod" if args.lang == "ru" else f"dragoncave_{args.lang}.mod")
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    data = build_module(args.lang)
    with open(out, "wb") as f:
        f.write(data)
    print(f"Wrote {out} ({len(data)} bytes)")


if __name__ == "__main__":
    main()
