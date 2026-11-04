// ath_dome_d — OnDeath разрушаемого купола (карточка 9).
// 50%: вздутый труп с личинкой; иначе рабочий везер. Под куполом — пробка в улей.

#include "ath_inc_b2"

void main()
{
    location lHere = GetLocation(OBJECT_SELF);
    object oKiller = GetLastKiller();
    if (d2() == 1)
    {
        CreateObject(OBJECT_TYPE_PLACEABLE, ATH_RES_CORPSE, lHere);
        CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_LARVA, lHere);
        AthTextToPCsIn(GetArea(OBJECT_SELF), ATH_TXT2_CORPSE);
    }
    else
    {
        object oWorker = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_WORKER, lHere);
        if (GetIsObjectValid(oKiller))
            AssignCommand(oWorker, ActionAttack(oKiller));
        AthTextToPCsIn(GetArea(OBJECT_SELF), ATH_TXT2_WORKER);
    }
    CreateObject(OBJECT_TYPE_PLACEABLE, ATH_RES_PLUG, lHere);
    AthJournal2(oKiller, ATH_J2_HIVE);
}
