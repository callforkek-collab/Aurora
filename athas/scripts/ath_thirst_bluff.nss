// ath_thirst_bluff — Action Taken в ath_dlg_thirsty: «В Урике вас самих закуют».
// Блеф: при успехе часть охраны уходит, с остальными бой.

#include "ath_inc_s4"

void main()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(OBJECT_SELF);
    if (GetIsSkillSuccessful(oPC, SKILL_BLUFF, ATH_DC_BLUFF))
        AthThirstyLeave(oArea, ATH_BLUFF_LEAVE);
    AthThirstyFight(oArea);
}
