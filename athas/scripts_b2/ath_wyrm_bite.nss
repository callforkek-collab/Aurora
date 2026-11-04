// ath_wyrm_bite — tag-based укус змея (On Hit: Unique Power).
// Стойкость DC 14, иначе паралич: герой приходит в себя в коконе в логове змея.

#include "x2_inc_switches"
#include "ath_inc_b2"

void AthAbduct(object oVictim)
{
    if (GetIsDead(oVictim))
        return;
    AssignCommand(oVictim, ClearAllActions(TRUE));
    AssignCommand(oVictim, JumpToObject(GetWaypointByTag(ATH_WP_COCOON)));
    SetLocalInt(oVictim, "ATH_IN_COCOON", 1);
    effect eHold = TagEffect(SupernaturalEffect(EffectCutsceneImmobilize()), "ATH_COCOON_HOLD");
    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHold, oVictim));
    if (!GetIsObjectValid(GetItemPossessedBy(oVictim, ATH_RES_COCOON)))
        CreateItemOnObject(ATH_RES_COCOON, oVictim);
    DelayCommand(2.0, FadeFromBlack(oVictim, FADE_SPEED_SLOW));
    DelayCommand(4.0, FloatingTextStringOnCreature(ATH_TXT2_COCOON, oVictim, FALSE));
}

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ONHITCAST)
        return;
    object oVictim = GetSpellTargetObject();
    object oWyrm = GetItemPossessor(GetSpellCastItem());
    if (!GetIsPC(oVictim) || GetLocalInt(oVictim, "ATH_IN_COCOON")
        || FortitudeSave(oVictim, ATH_DC_WYRM, SAVING_THROW_TYPE_POISON) != 0)
        return;

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectParalyze(), oVictim, 6.0);
    FloatingTextStringOnCreature(ATH_TXT2_PARALYZED, oVictim, FALSE);
    FadeToBlack(oVictim, FADE_SPEED_MEDIUM);
    AssignCommand(oVictim, DelayCommand(3.0, AthAbduct(oVictim)));

    // Змей уносит добычу в логово и успокаивается.
    AssignCommand(oWyrm, ClearAllActions(TRUE));
    ChangeToStandardFaction(oWyrm, STANDARD_FACTION_COMMONER);
    SetLocalInt(oWyrm, "ATH_ATTACK", 0);
    SetLocalInt(oWyrm, "ATH_FED", 1);
    AssignCommand(oWyrm, ActionJumpToObject(GetWaypointByTag(ATH_WP_LAIR)));
}
