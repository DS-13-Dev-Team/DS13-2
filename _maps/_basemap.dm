#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\debug\multiz.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\AegisVII\AegisVII_Low.dmm"
		#include "map_files\AegisVII\AegisVII_Middle.dmm"
		#include "map_files\AegisVII\AegisVII_High.dmm"
		#include "map_files\Mara17\Mara17_Low.dmm"
		#include "map_files\Mara17\Mara17_Middle.dmm"
		#include "map_files\Mara17\Mara17_High.dmm"

		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
