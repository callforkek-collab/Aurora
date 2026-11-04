// ath_wyrm_go — карточка 13. Вызывается из ath_b2_rest (OBJECT_SELF = отдыхающий герой):
// рядом появляется невидимый шёлковый змей и начинает пить воду.

#include "ath_inc_b2"

void main()
{
    object oPC = OBJECT_SELF;
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_WYRM_DONE"))
        return;
    SetLocalInt(oModule, "ATH_WYRM_DONE", 1);

    vector vPos = GetPosition(oPC);
    location lNear = Location(GetArea(oPC), Vector(vPos.x + 4.0, vPos.y + 4.0, vPos.z), GetFacing(oPC));
    object oWyrm = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WYRM, lNear);
    effect eHide = TagEffect(SupernaturalEffect(EffectInvisibility(INVISIBILITY_TYPE_NORMAL)), "ATH_WYRM_HIDE");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHide, oWyrm);
    SetLocalObject(oWyrm, "ATH_PREY", oPC);
}
