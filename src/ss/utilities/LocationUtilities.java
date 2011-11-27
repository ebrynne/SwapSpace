package ss.utilities;

import java.util.Map;
import java.util.TreeMap;

import ss.beans.StaticResources;

public class LocationUtilities {
	
	double latitude;
	double longitude;
	
	public LocationUtilities(int [] location){
		if(location[0] != -1){
			StaticResources sr = StaticResources.getStaticResources();
			TreeMap<Double, Integer> blockRows = sr.getblockMap();
			Double latRow = 0.0;
			for(Map.Entry<Double, Integer> blockMap : blockRows.entrySet()){
				System.out.print(blockMap.getKey() + ":");
				latRow = blockMap.getKey();
				if (blockMap.getValue() > location[0]) break;
			}
			if(blockRows.get(latRow) < location[0]){
				latRow = blockRows.lastKey();
			}
			double vOffset = sr.getLatitudeBlockSize();
			double hOffset = blockRows.get(latRow) < location[0] ? 360/sr.getNumBlocksFinalRow() : 360/(blockRows.lowerKey(latRow) - blockRows.get(latRow));
			latitude = latRow.doubleValue() + ((((int)(location[3]/10)) + (location[3] % 10 == 0 ? -1 : 0))*vOffset) + (.05 * vOffset);
			longitude = -180 + (location[0] * hOffset) + (location[3] % 10 == 0 ? .9 * hOffset : (((location[3] % 10) - 1) / 10) * hOffset) + .05+hOffset;
		}	
	}


	
	public double calcDistance(int [] loc2){
		return 0.0;
	}
	
	public double getLatitude(){
		return latitude;
	}
	
	public double getLongitude(){
		return longitude;
	}
}
