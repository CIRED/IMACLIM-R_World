if current_time_im==1
    warning("Zeroing basic needs");
end

bn           = bn           *max(0,(20-current_time_im)/19);
bnNM         = bnNM         *max(0,(20-current_time_im)/19);
bnautomobile = bnautomobile *max(0,(20-current_time_im)/19);
bnOT         = bnOT         *max(0,(20-current_time_im)/19);
bnair        = bnair        *max(0,(20-current_time_im)/19);
