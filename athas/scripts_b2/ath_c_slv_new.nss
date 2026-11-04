// ath_c_slv_new — условие первой встречи в ath_dlg_slaves: сделки ещё нет.

int StartingConditional()
{
    return !GetLocalInt(GetModule(), "ATH_SLV_DEAL") && !GetLocalInt(GetModule(), "ATH_SLV_DONE");
}
