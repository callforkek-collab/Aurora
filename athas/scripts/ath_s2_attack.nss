// ath_s2_attack — сцена 2, нападение Джура-Дай. Выполняется на модуле:
// из ath_s1_loop (игрок вырвал петлю) или по таймеру из ath_start.

#include "ath_inc_thirst"

void AthBark(string sTag, string sText)
{
    object oSpeaker = GetObjectByTag(sTag);
    if (GetIsObjectValid(oSpeaker))
        AssignCommand(oSpeaker, SpeakString(sText, TALKVOLUME_SHOUT));
}

void AthStrike()
{
    object oWagon = GetObjectByTag(ATH_TAG_AREA_WAGON);
    object oPoint = GetWaypointByTag(ATH_WP_LIGHTNING);
    if (GetIsObjectValid(oPoint))
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_M), GetLocation(oPoint));
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == oWagon)
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), oPC);
        oPC = GetNextPC();
    }
}

// Охрана занимает боевые посты и забывает о рабах.
void AthCrewToStations()
{
    object oDeck = GetWaypointByTag(ATH_WP_DECK);
    int i = 0;
    object oGuard = GetObjectByTag(ATH_TAG_GUARD, i);
    while (GetIsObjectValid(oGuard))
    {
        AssignCommand(oGuard, ClearAllActions());
        AssignCommand(oGuard, ActionMoveToObject(oDeck, TRUE));
        i++;
        oGuard = GetObjectByTag(ATH_TAG_GUARD, i);
    }
    object oHold = GetObjectByTag(ATH_TAG_HOLD_GUARD);
    AssignCommand(oHold, ClearAllActions());
    AssignCommand(oHold, ActionMoveToObject(oDeck, TRUE));
}

void AthOpenDoors()
{
    int i = 0;
    object oDoor = GetObjectByTag(ATH_TAG_HOLD_DOOR, i);
    while (GetIsObjectValid(oDoor))
    {
        SetLocked(oDoor, FALSE);
        AssignCommand(oDoor, ActionOpenDoor(oDoor));
        i++;
        oDoor = GetObjectByTag(ATH_TAG_HOLD_DOOR, i);
    }
}

// Тем, кто ещё в кандалах, псионик предлагает сделку (диалог ath_dlg_psion).
void AthOfferDeal()
{
    object oPsion = GetObjectByTag(ATH_TAG_PSION);
    if (!GetIsObjectValid(oPsion))
        return;
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetLocalInt(oPC, "ATH_SHACKLED") && GetArea(oPC) == GetArea(oPsion))
        {
            AssignCommand(oPsion, ClearAllActions());
            AssignCommand(oPsion, ActionMoveToObject(oPC, TRUE, 2.0));
            AssignCommand(oPsion, ActionStartConversation(oPC, ATH_DLG_PSION, FALSE, FALSE));
            return; // один разговор за раз; остальных освободят эльфы
        }
        oPC = GetNextPC();
    }
}

void AthCountdown(int nLeft)
{
    object oWagon = GetObjectByTag(ATH_TAG_AREA_WAGON);
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == oWagon)
            SendMessageToPC(oPC, ATH_TXT_COUNTDOWN + IntToString(nLeft) + ATH_TXT_SECONDS);
        oPC = GetNextPC();
    }
}

void main()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_S2"))
        return;
    SetLocalInt(oModule, "ATH_S2", 1);
    AthJournalAll(ATH_J_ATTACK);

    AthBark(ATH_TAG_HOLD_GUARD, ATH_TXT_ALARM);
    AthCrewToStations();
    DelayCommand(2.0, AthBark(ATH_TAG_VOICE, ATH_TXT_ULTIMATUM_1));
    DelayCommand(8.0, AthStrike());
    DelayCommand(9.0, AthBark(ATH_TAG_GUARD, ATH_TXT_STOP_1));
    DelayCommand(11.0, AthBark(ATH_TAG_HOLD_GUARD, ATH_TXT_STOP_2));
    DelayCommand(13.0, AthBark(ATH_TAG_PSION, ATH_TXT_STOP_3));
    DelayCommand(16.0, AthBark(ATH_TAG_VOICE, ATH_TXT_ULTIMATUM_2));
    DelayCommand(18.0, AthOpenDoors());
    DelayCommand(19.0, AthOfferDeal());

    float fStart = 20.0;
    DelayCommand(fStart, AthCountdown(FloatToInt(ATH_SEARCH_TIME)));
    DelayCommand(fStart + ATH_SEARCH_TIME - 30.0, AthCountdown(30));
    DelayCommand(fStart + ATH_SEARCH_TIME - 10.0, AthCountdown(10));
    DelayCommand(fStart + ATH_SEARCH_TIME, ExecuteScript("ath_s2_elves", oModule));
}
