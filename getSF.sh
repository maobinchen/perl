cat *.silent >temp.out
sed 's/SCORE:     score       time    user_tag    description/SCORE:     score     fa_atr     fa_rep     fa_sol    fa_intra_rep    pro_close    fa_pair    hbond_sr_bb    hbond_lr_bb    hbond_bb_sc    hbond_sc    dslf_ss_dst    dslf_cs_ang    dslf_ss_dih    dslf_ca_dih       rama      omega     fa_dun    p_aa_pp        ref       time    user_tag    description/' temp.out >all.out
rm temp.out
~/bin/getScoreFromSilents.sh all.out
sed '/^SCORE:     0.000/d' score.sc >score1.sc
mv score1.sc score.sc
