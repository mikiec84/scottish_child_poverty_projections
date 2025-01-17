#!/bin/sh
# individual years forecast, zero eu migration, scotland only
#./parse_forecast_files.rb  pp-2014-based-add-var-euro-zeroeumig-scotland-syoa-1.tab zeroeu SCO 2014 NRS
#./parse_forecast_files.rb  pp-2014-based-add-var-euro-150percenteumig-scotland-syoa.tab eu-150pc SCO 2014 NRS
#./parse_forecast_files.rb  pp-2014-based-add-var-euro-50percenteumig-scotland-syoa.tab eu-50pc SCO 2014 NRS
#./parse_forecast_files.rb  14-pop-proj-scotland-syoa.tab baseline  SCO 2014 NRS

#
# ons
#
# ./parse_forecast_files.rb sc_plp_opendata2014.txt plp SCO 2014 ONS persons


./parse_forecast_files.rb sc_cnp_opendata2014.txt   cnp SCO 2014 ONS persons
./parse_forecast_files.rb sc_hhh_opendata2014.txt   hhh SCO 2014 ONS persons
./parse_forecast_files.rb sc_hpp_opendata2014.txt   hpp SCO 2014 ONS persons
./parse_forecast_files.rb sc_lll_opendata2014.txt   lll SCO 2014 ONS persons
./parse_forecast_files.rb sc_php_opendata2014.txt   php SCO 2014 ONS persons
./parse_forecast_files.rb sc_pnp_opendata2014.txt   pnp SCO 2014 ONS persons
./parse_forecast_files.rb sc_ppl_opendata2014.txt   ppl SCO 2014 ONS persons
./parse_forecast_files.rb sc_ppz_opendata2014.txt   ppz SCO 2014 ONS persons
./parse_forecast_files.rb sc_cpp_opendata2014.txt   cpp SCO 2014 ONS persons
./parse_forecast_files.rb sc_hlh_opendata2014.txt   hlh SCO 2014 ONS persons
./parse_forecast_files.rb sc_lhl_opendata2014.txt   lhl SCO 2014 ONS persons
./parse_forecast_files.rb sc_lpp_opendata2014.txt   lpp SCO 2014 ONS persons
./parse_forecast_files.rb sc_plp_opendata2014.txt   plp SCO 2014 ONS persons
./parse_forecast_files.rb sc_pph_opendata2014.txt   pph SCO 2014 ONS persons
./parse_forecast_files.rb sc_ppp_opendata2014.txt   ppp SCO 2014 ONS persons
./parse_forecast_files.rb sc_rpp_opendata2014.txt   rpp SCO 2014 ONS persons

./parse_forecast_files.rb 2014-ppp-house-proj.tab   ppp SCO 2014 NRS households
./parse_forecast_files.rb 2014-ppl-house-proj.tab   ppl SCO 2014 NRS households
./parse_forecast_files.rb 2014-pph-house-proj.tab   pph SCO 2014 NRS households


./parse_forecast_files.rb uk_ppz_opendata2014.txt ppz UK 2014 ONS persons
./parse_forecast_files.rb uk_ppp_opendata2014.txt ppp UK 2014 ONS persons
./parse_forecast_files.rb uk_ppl_opendata2014.txt ppl UK 2014 ONS persons
./parse_forecast_files.rb uk_pph_opendata2014.txt pph UK 2014 ONS persons
./parse_forecast_files.rb uk_plp_opendata2014.txt plp UK 2014 ONS persons
./parse_forecast_files.rb uk_php_opendata2014.txt php UK 2014 ONS persons
./parse_forecast_files.rb uk_lpp_opendata2014.txt lpp UK 2014 ONS persons
./parse_forecast_files.rb uk_lll_opendata2014.txt lll UK 2014 ONS persons
./parse_forecast_files.rb uk_hpp_opendata2014.txt hpp UK 2014 ONS persons
./parse_forecast_files.rb uk_hhh_opendata2014.txt hhh UK 2014 ONS persons



