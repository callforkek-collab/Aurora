// ath_c_slv_wait — условие «Чего ждёшь? Ночью — в лагерь»: сделка есть, герой ещё не ходил.

int StartingConditional()
{
    object oModule = GetModule();
    return GetLocalInt(oModule, "ATH_SLV_DEAL") && !GetLocalInt(oModule, "ATH_SLV_DONE")
        && !GetLocalInt(GetPCSpeaker(), "ATH_CAMP_TRIED");
}
