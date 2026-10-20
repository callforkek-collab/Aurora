// ath_chief_hostile — Action Taken в ath_dlg_chief: «Вода и оружие — моё».
// Все эльфы в локации становятся враждебны; повозку всё равно поджигают.

#include "ath_inc_const"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE
            && GetStringLeft(GetTag(oObject), GetStringLength(ATH_TAG_ELF)) == ATH_TAG_ELF)
            ChangeToStandardFaction(oObject, STANDARD_FACTION_HOSTILE);
        oObject = GetNextObjectInArea(oArea);
    }
    object oModule = GetModule();
    SetLocalInt(oModule, "ATH_ELVES_HOSTILE", 1);
    AssignCommand(oModule, DelayCommand(ATH_FIRE_DELAY, ExecuteScript("ath_s3_fire", oModule)));
}
