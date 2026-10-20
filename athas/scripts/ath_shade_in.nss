// ath_shade_in — OnEnter триггера тени (у скал, у стен повозки).

void main()
{
    SetLocalInt(GetEnteringObject(), "ATH_IN_SHADE", 1);
}
