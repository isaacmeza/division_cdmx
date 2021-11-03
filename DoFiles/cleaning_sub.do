
import delimited  "$directory\_aux\cp_exp_unique_.csv", clear
destring sub reg_sub, replace force
sort region cp del col lat lon

*Imputation


replace reg_sub = 1 in 5
replace reg_sub = 1 in 27
replace reg_sub = 1 in 51
replace reg_sub = 1 in 54
replace reg_sub = 2 in 69
replace reg_sub = 6 in 79
replace reg_sub = 6 in 80
replace reg_sub = 4 in 85
replace reg_sub = 3 in 97
replace reg_sub = . in 108
replace reg_sub = 2 in 108
replace reg_sub = 2 in 116
replace reg_sub = 2 in 121
replace reg_sub = 2 in 136
replace reg_sub = 3 in 153
replace reg_sub = 6 in 155
replace reg_sub = 6 in 158
replace reg_sub = 6 in 162
replace reg_sub = 6 in 166
replace reg_sub = 6 in 169
replace reg_sub = 6 in 170
replace reg_sub = 6 in 171
replace reg_sub = 6 in 176
replace reg_sub = 6 in 177
replace reg_sub = 6 in 178
replace reg_sub = 6 in 180
replace reg_sub = 6 in 181
replace reg_sub = 6 in 182
replace reg_sub = 6 in 184
replace reg_sub = 3 in 186
replace reg_sub = 3 in 187
replace reg_sub = 13 in 190
replace reg_sub = 10 in 196
replace reg_sub = 10 in 199
replace reg_sub = 10 in 200
replace reg_sub = 8 in 204
replace reg_sub = 8 in 206
replace reg_sub = 8 in 211
replace reg_sub = 10 in 208
replace reg_sub = 8 in 210
replace reg_sub = 8 in 213
replace reg_sub = 8 in 214
replace reg_sub = 9 in 217
replace reg_sub = 9 in 219
replace reg_sub = 9 in 220
replace reg_sub = 13 in 236
replace reg_sub = 13 in 241
replace reg_sub = 10 in 250
replace reg_sub = 9 in 258
replace reg_sub = 9 in 261
replace reg_sub = 9 in 263
replace reg_sub = 13 in 269
replace reg_sub = 13 in 275
replace reg_sub = 13 in 281
replace reg_sub = 14 in 288
replace reg_sub = 12 in 298
replace reg_sub = 12 in 302
replace reg_sub = 13 in 321
replace reg_sub = 8 in 324
replace reg_sub = 14 in 339
replace reg_sub = 14 in 340
replace reg_sub = 14 in 347
replace reg_sub = 14 in 348
replace reg_sub = 16 in 354
replace reg_sub = 16 in 357
replace reg_sub = 16 in 358
replace reg_sub = 16 in 359
replace reg_sub = 16 in 360
replace reg_sub = 16 in 362
replace reg_sub = 16 in 363
replace reg_sub = 16 in 364
replace reg_sub = 16 in 365
replace reg_sub = 16 in 366
replace reg_sub = 16 in 367
replace reg_sub = 16 in 368
replace reg_sub = 16 in 370
replace reg_sub = 16 in 371
replace reg_sub = 16 in 372
replace reg_sub = 16 in 374
replace reg_sub = 16 in 385
replace reg_sub = 16 in 388
replace reg_sub = 16 in 398
replace reg_sub = 16 in 400
replace reg_sub = 16 in 404
replace reg_sub = 16 in 405
replace reg_sub = 16 in 406
replace reg_sub = 15 in 402
replace reg_sub = 15 in 403
replace reg_sub = 17 in 464
replace reg_sub = 17 in 465
replace reg_sub = 17 in 468
replace reg_sub = 17 in 470
replace reg_sub = 18 in 477
replace reg_sub = 18 in 481
replace reg_sub = 19 in 485
replace reg_sub = 17 in 498
replace reg_sub = 17 in 501
replace reg_sub = 21 in 515
replace reg_sub = 21 in 526
replace reg_sub = 21 in 539
replace reg_sub = 21 in 543
replace reg_sub = 22 in 560
replace reg_sub = 22 in 575
replace reg_sub = 22 in 578
replace reg_sub = 22 in 584
replace reg_sub = 22 in 587
replace reg_sub = 29 in 595
replace reg_sub = 26 in 612
replace reg_sub = 29 in 614
replace reg_sub = 27 in 616
replace reg_sub = 29 in 629
replace reg_sub = 30 in 651
replace reg_sub = 35 in 673
replace reg_sub = 40 in 713
replace reg_sub = 50 in 813
replace reg_sub = 51 in 816
replace reg_sub = 51 in 819
replace reg_sub = 48 in 830
replace reg_sub = 48 in 833
replace reg_sub = 50 in 836
replace reg_sub = 51 in 842
replace reg_sub = 47 in 847

codebook reg_sub

export delimited using "$directory\_aux\cp_exp_unique_1.csv", quote replace

collapse (sum) num_diligencias_sub = num_diligencias_cpxgeo (sum) num_addr_sub = num_addr_cpxgeo (sum) area_sqkm_sub = area_sqkm (mean) lat_c (mean) lon_c (mean) region, by(reg_sub)
export delimited using "$directory\_aux\sub_exp_unique.csv", quote replace
