// ath_c_slv_done — условие прощальной реплики: расчёт уже был.

int StartingConditional()
{
    return GetLocalInt(GetModule(), "ATH_SLV_DONE");
}
